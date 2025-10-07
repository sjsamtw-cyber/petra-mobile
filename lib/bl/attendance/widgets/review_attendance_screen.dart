import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_class.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/services/attendance.service.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/shared/class_selector_dropdown.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/user_constants.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/petra_student.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_gender.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/student_avatar.dart';
import 'package:provider/provider.dart';

class ReviewAttendanceScreen extends StatefulWidget {
  static const String page = 'ReviewAttendanceScreen';

  const ReviewAttendanceScreen({super.key});

  @override
  State<ReviewAttendanceScreen> createState() => _ReviewAttendanceScreenState();
}

class _ReviewAttendanceScreenState extends State<ReviewAttendanceScreen> {
  // Common state
  DateTime selectedDate = DateTime.now();
  bool isLoading = false; // Initial loading (classes/children)
  bool isDateLoading = false; // Per-date loading for attendance records
  String? errorMessage;

  // Teacher-specific state
  List<PetraClass> classes = [];
  PetraClass? selectedClass;
  List<Map<String, dynamic>> attendanceRecords = [];

  // Per-date cache for teacher attendance records to avoid redundant API calls
  // Map structure: {DateTime: {classId: AttendanceData}} for efficient date-first lookup
  // This enables instant date switching with cached data and progressive loading of new dates
  final Map<DateTime, Map<int, List<Map<String, dynamic>>>> _perDateCache = {};

  // Parent-specific state
  List<PetraStudent> children = [];
  PetraStudent? selectedChild;
  Map<String, dynamic>? childAttendance;

  // Parent attendance cache: {childId: {date: record}}
  final Map<int, Map<String, Map<String, dynamic>>> _parentAttendanceCache = {};

  // User type
  UserType? userType;
  final AppPreferences _appPreferences = AppPreferences();

  // Academic year
  DateTime? academicYearStart;
  DateTime? academicYearEnd;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    final user = context.read<PetraUser>();
    userType = user.userType;

    if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
      await _loadClasses();
    } else if (userType == UserType.PARENT) {
      await _loadChildren();
    }
  }

  Future<void> _loadClasses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiToken = _appPreferences.fetchStringSharedPref(
        UserPreferenceKeys.apiTokenKey,
      );
      if (apiToken == null) {
        throw Exception('Authentication token not found');
      }

      final response = await AttendanceService.getTeacherClasses(apiToken);

      if (AttendanceService.isValidResponse(response)) {
        // Extract academic year from response
        final message = response['message'];
        if (message != null && message['acad_year'] != null) {
          final acadYear = message['acad_year'] as String;
          final parts = acadYear.split('|');
          if (parts.length == 2) {
            academicYearStart = _parseDate(parts[0]);
            academicYearEnd = _parseDate(parts[1]);
          }
        }
        final loadedClasses = AttendanceService.parseClassesFromResponse(
          response,
        );
        setState(() {
          classes = loadedClasses;
          if (classes.isNotEmpty) {
            selectedClass = classes.first;
            _loadAttendanceRecords();
          }
        });
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load classes: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime? _parseDate(String s) {
    // Expects dd-MM-yyyy
    try {
      final parts = s.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      debugPrint('Error parsing date: $s - $e');
    }
    return null;
  }

  Future<void> _loadChildren() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiToken = _appPreferences.fetchStringSharedPref(
        UserPreferenceKeys.apiTokenKey,
      );
      if (apiToken == null) {
        throw Exception('Authentication token not found');
      }

      // Use parent historical attendance API to get children and their attendance data
      final response = await AttendanceService.getParentHistoricalAttendance(
        apiToken,
      );

      if (AttendanceService.isValidResponse(response)) {
        // Parse children from the response and build attendance cache
        final message = response['message'] as Map<String, dynamic>?;
        final Set<PetraStudent> childrenSet = {};

        if (message != null) {
          // Extract academic year if available
          if (message['acad_year'] != null) {
            final acadYear = message['acad_year'] as String;
            if (kDebugMode) {
              print('Academic year string from API: $acadYear');
            }
            final parts = acadYear.split('|');
            if (parts.length == 2) {
              academicYearStart = _parseDate(parts[0]);
              academicYearEnd = _parseDate(parts[1]);
              if (kDebugMode) {
                print(
                  'Academic year parsed: ${academicYearStart?.toIso8601String()} to ${academicYearEnd?.toIso8601String()}',
                );
              }
            } else {
              if (kDebugMode) {
                print('Failed to split academic year: $acadYear');
              }
            }
          } else {
            if (kDebugMode) {
              print('No academic year found in API response');
            }
          }

          // Parse student name-id mapping
          final studentNameIdMap =
              message['student_name_id_map'] as Map<String, dynamic>?;

          if (kDebugMode) {
            print('Student name-id map: $studentNameIdMap');
          }

          // Parse dates and build cache + children list
          if (message['dates'] is Map<String, dynamic>) {
            final dates = message['dates'] as Map<String, dynamic>;
            if (kDebugMode) {
              print('Available dates in response: ${dates.keys.join(', ')}');
            }
            final Map<int, PetraStudent> childrenMap = {};

            for (final dateKey in dates.keys) {
              final records = dates[dateKey] as List<dynamic>?;
              if (records != null) {
                for (final rec in records) {
                  if (rec is Map<String, dynamic> && rec['user_id'] != null) {
                    final int childId = rec['user_id'] is int
                        ? rec['user_id']
                        : int.tryParse(rec['user_id'].toString()) ?? 0;

                    // Build attendance cache
                    _parentAttendanceCache.putIfAbsent(childId, () => {});
                    _parentAttendanceCache[childId]![dateKey] = rec;

                    // Create PetraStudent from the record (only if not already created)
                    if (!childrenMap.containsKey(childId)) {
                      final child = PetraStudent(
                        studentDetailId: childId,
                        firstName: rec['first_name'] ?? 'Unknown',
                        middleName: rec['middle_name'] ?? '',
                        lastName: rec['last_name'] ?? '',
                        gender: rec['gender'] != null
                            ? UserGenderDetails.getGenderFromNumber(
                                rec['gender'],
                              )
                            : null,
                        classDetailID: rec['class_detail_id'] ?? 0,
                        classDivision: rec['class_division'] ?? '',
                        classHRName: rec['class_hr_name'] ?? '',
                        teacherId: rec['class_teacher_id'] ?? 0,
                        imageUrl:
                            rec['photo_url'] != 'na' && rec['photo_url'] != null
                            ? rec['photo_url']
                            : null,
                      );
                      childrenMap[childId] = child;

                      if (kDebugMode) {
                        print(
                          'Created PetraStudent for child ID $childId: ${child.firstName} ${child.lastName}',
                        );
                      }
                    }
                  }
                }
              }
            }

            // Convert map values to set to ensure uniqueness
            childrenSet.addAll(childrenMap.values);
          }
        }

        setState(() {
          children = childrenSet.toList();
          if (kDebugMode) {
            print('Total children loaded: ${children.length}');
          }
          if (children.isNotEmpty) {
            selectedChild = children.first;
            _loadChildAttendance();
          }
        });
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load children: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAttendanceRecords() async {
    if (selectedClass == null) return;

    final classId = selectedClass!.classDetailID;

    // Check if we have cached data for this specific date and class
    if (_isAttendanceCached(selectedDate, classId)) {
      // We have cached records for this specific date and class
      final cachedRecords = _getCachedAttendance(selectedDate, classId)!;
      setState(() {
        attendanceRecords = cachedRecords;
      });
      if (kDebugMode) {
        print(
          'Using cached data for class $classId on ${selectedDate.toIso8601String().split('T')[0]} (${cachedRecords.length} records)',
        );
        print('Cache stats: ${_getCacheStats()}');
      }
      return;
    }

    setState(() {
      isDateLoading =
          true; // Use date-specific loading instead of general loading
      errorMessage = null;
    });

    try {
      final apiToken = _appPreferences.fetchStringSharedPref(
        UserPreferenceKeys.apiTokenKey,
      );
      if (apiToken == null) {
        throw Exception('Authentication token not found');
      }

      if (kDebugMode) {
        print(
          'Making API call for class $classId on ${selectedDate.toIso8601String().split('T')[0]}',
        );
      }

      // This API now returns data for the specific selected date only
      final response = await AttendanceService.getAttendanceByClassAndDate(
        apiToken,
        classId,
        selectedDate,
      );

      if (AttendanceService.isValidResponse(response)) {
        // Build the date-based cache from the single-date response
        final dateCacheForClass =
            AttendanceService.buildDateBasedCacheFromResponse(response);

        // Store data in the new per-date cache structure using helper method
        dateCacheForClass.forEach((dateStr, records) {
          // Parse the date string back to DateTime for proper indexing
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            final responseDate = DateTime(
              int.parse(parts[0]), // year
              int.parse(parts[1]), // month
              int.parse(parts[2]), // day
            );

            _storeAttendanceInCache(responseDate, classId, records);
          }
        });

        // Extract records for the currently selected date
        final currentRecords = _getCachedAttendance(selectedDate, classId);
        setState(() {
          attendanceRecords = currentRecords ?? [];
        });
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load attendance records: ${e.toString()}';
      });
    } finally {
      setState(() {
        isDateLoading = false; // Use date-specific loading flag
      });
    }
  }

  /// Helper method to normalize date for caching (removes time component)
  DateTime _normalizeDateForCache(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if attendance data is cached for a specific date and class
  bool _isAttendanceCached(DateTime date, int classId) {
    final dateKey = _normalizeDateForCache(date);
    return _perDateCache.containsKey(dateKey) &&
        _perDateCache[dateKey]!.containsKey(classId);
  }

  /// Get cached attendance data for a specific date and class
  List<Map<String, dynamic>>? _getCachedAttendance(DateTime date, int classId) {
    final dateKey = _normalizeDateForCache(date);
    return _perDateCache[dateKey]?[classId];
  }

  /// Store attendance data in per-date cache
  void _storeAttendanceInCache(
    DateTime date,
    int classId,
    List<Map<String, dynamic>> records,
  ) {
    final dateKey = _normalizeDateForCache(date);
    _perDateCache.putIfAbsent(dateKey, () => {});
    _perDateCache[dateKey]![classId] = records;

    if (kDebugMode) {
      print(
        'Stored attendance data for class $classId on ${dateKey.toIso8601String().split('T')[0]} (${records.length} records)',
      );
      print('Cache now contains ${_perDateCache.length} dates');
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> _getCacheStats() {
    int totalEntries = 0;
    final dateCount = _perDateCache.length;

    _perDateCache.forEach((date, classMap) {
      totalEntries += classMap.values
          .map((records) => records.length)
          .fold(0, (a, b) => a + b);
    });

    return {
      'cached_dates': dateCount,
      'total_records': totalEntries,
      'dates': _perDateCache.keys
          .map((d) => d.toIso8601String().split('T')[0])
          .toList(),
    };
  }

  Future<void> _loadChildAttendance() async {
    if (selectedChild == null) return;

    final childId = selectedChild!.studentDetailId;
    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    // Extract from cache - data should already be loaded in _loadChildren
    if (_parentAttendanceCache.containsKey(childId) &&
        _parentAttendanceCache[childId]!.containsKey(dateStr)) {
      if (kDebugMode) {
        print('Found attendance record for child $childId on date $dateStr');
      }
      setState(() {
        childAttendance = _parentAttendanceCache[childId]![dateStr];
        isDateLoading = false; // Reset loading state
      });
    } else {
      if (kDebugMode) {
        print('No attendance record found for child $childId on date $dateStr');
      }
      setState(() {
        childAttendance = null; // No attendance record for this date
        isDateLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : errorMessage != null
            ? _buildErrorWidget(l10n, theme)
            : Column(
                children: [
                  // Dropdown (Class or Child)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: _buildDropdownSection(l10n, theme),
                  ),

                  // Date Selection
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildDateSelectionSection(l10n, theme),
                  ),

                  const SizedBox(height: 24),

                  // Results Section
                  Expanded(child: _buildResultsSection(l10n, theme)),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              key: const Key('retryLoadingButton'),
              onPressed: _initializeScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                  vertical: 14.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: const Size(120, 48),
              ),
              child: Text(
                'Retry',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection(AppLocalizations l10n, ThemeData theme) {
    if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
      return ClassSelectorDropdown(
        classes: classes,
        selectedClass: selectedClass,
        onClassChanged: (PetraClass? newClass) {
          setState(() {
            selectedClass = newClass;
          });
          if (newClass != null) {
            _loadAttendanceRecords();
          }
        },
      );
    } else if (userType == UserType.PARENT) {
      return _buildChildDropdown(l10n, theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildChildDropdown(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectChild, // Using localized string with fallback
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PetraStudent>(
              key: const Key('reviewChildDropdown'),
              value: selectedChild,
              hint: Text(
                l10n.selectChild,
              ), // Using localized string with fallback
              onChanged: (PetraStudent? newChild) {
                setState(() {
                  selectedChild = newChild;
                });
                if (newChild != null) {
                  _loadChildAttendance();
                }
              },
              items: children.map<DropdownMenuItem<PetraStudent>>((
                PetraStudent child,
              ) {
                return DropdownMenuItem<PetraStudent>(
                  value: child,
                  child: Text(
                    '${child.firstName} ${child.middleName} ${child.lastName}'
                        .trim(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(AppLocalizations l10n, ThemeData theme) {
    // Use academic year dates if available, otherwise default to sensible values
    // For parents, allow selection of all dates in academic year
    // For teachers, restrict based on their needs
    DateTime? minDate = academicYearStart;
    DateTime? maxDate;

    if (userType == UserType.PARENT) {
      // For parents: allow selection from academic year start to current date
      minDate = academicYearStart;
      maxDate = DateTime.now();
    } else {
      // For teachers/admins: use academic year or default to today
      maxDate =
          academicYearEnd != null && academicYearEnd!.isBefore(DateTime.now())
          ? academicYearEnd
          : DateTime.now();
    }

    if (kDebugMode) {
      print(
        'Calendar date range: ${minDate?.toIso8601String()} to ${maxDate?.toIso8601String()}',
      );
    }

    return PetraCalendar(
      key: const Key('reviewAttendanceCalendar'),
      selectedDate: selectedDate,
      selectionMode: CalendarSelectionMode.single,
      showSelectedDateIndicator: true,
      minDate: minDate,
      maxDate: maxDate,
      onDateChanged: (DateTime date) {
        setState(() {
          selectedDate = date;
          // Show date-specific loading if data is not cached
          if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
            if (!_isAttendanceCached(
              date,
              selectedClass?.classDetailID ?? -1,
            )) {
              isDateLoading = true;
            }
          }
          // Note: Parents don't need loading state since all data is pre-cached
        });
        if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
          _loadAttendanceRecords();
        } else if (userType == UserType.PARENT) {
          _loadChildAttendance();
        }
      },
    );
  }

  Widget _buildResultsSection(AppLocalizations l10n, ThemeData theme) {
    // Show date loading indicator if applicable
    if (isDateLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Loading attendance for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
      return _buildTeacherResults(l10n, theme);
    } else if (userType == UserType.PARENT) {
      return _buildParentResults(l10n, theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTeacherResults(AppLocalizations l10n, ThemeData theme) {
    if (attendanceRecords.isEmpty) {
      return _buildEmptyState(l10n, theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: attendanceRecords.length,
      itemBuilder: (context, index) {
        final record = attendanceRecords[index];

        // Create actual PetraStudent using all available data
        final student = PetraStudent(
          studentDetailId: record['user_id'] ?? 0,
          firstName: record['first_name'] ?? 'Unknown',
          middleName: record['middle_name'] ?? '',
          lastName: record['last_name'] ?? '',
          gender: record['gender'] != null
              ? UserGenderDetails.getGenderFromNumber(record['gender'])
              : null,
          classDetailID: record['class_id'] ?? 0,
          classDivision: record['class_division'] ?? '',
          classHRName: record['class_hr_name'] ?? '',
          teacherId: record['class_teacher_id'] ?? 0,
          imageUrl: record['photo_url'],
          attendanceStatus: record['attendance_status'] == 'p',
          remarks: record['remarks'],
        );

        return Container(
          key: Key('reviewAttendanceCard_${student.studentDetailId}'),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              // Student Avatar
              StudentAvatar(
                firstName: student.firstName,
                lastName: student.lastName,
                photoUrl: student.imageUrl,
                genderId: student.gender?.index == 0
                    ? 1
                    : 2, // Convert UserGender enum to int
                radius: 21,
              ),
              const SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.firstName} ${student.lastName}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (record['remarks'] != null &&
                        record['remarks'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.remarks}: ${record['remarks']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Attendance Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: student.attendanceStatus == true
                      ? theme.colorScheme.primary.withAlpha((255 * 0.1).round())
                      : theme.colorScheme.error.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  student.attendanceStatus == true ? l10n.present : l10n.absent,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: student.attendanceStatus == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParentResults(AppLocalizations l10n, ThemeData theme) {
    if (childAttendance == null) {
      // No attendance record for this date, show the empty state with localized message
      return _buildEmptyState(l10n, theme);
    }

    final isPresent = childAttendance!['attendance_status'] == 'p';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          key: Key('reviewStudentCard_${selectedChild!.studentDetailId}'),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Student Avatar
                  StudentAvatar(
                    firstName: selectedChild!.firstName,
                    lastName: selectedChild!.lastName,
                    photoUrl: selectedChild!.imageUrl,
                    genderId: selectedChild!.gender?.index == 0
                        ? 1
                        : 2, // Convert UserGender enum to int
                    radius: 21,
                  ),
                  const SizedBox(width: 16),

                  // Student Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedChild!.firstName} ${selectedChild!.middleName} ${selectedChild!.lastName}'
                              .trim(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.classLabel}: ${selectedChild!.classHRName} - ${selectedChild!.classDivision}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.studentId}: ${selectedChild!.studentDetailId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Attendance Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPresent
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPresent ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPresent ? l10n.present : l10n.absent,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Additional Details Section
              if (childAttendance!['remarks'] != null &&
                  childAttendance!['remarks'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.remarks,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        childAttendance!['remarks'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.attendanceInfoNotAvailable,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
