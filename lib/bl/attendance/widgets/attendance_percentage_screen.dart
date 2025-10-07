import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/services/attendance.service.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/user_constants.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/student_avatar.dart';
import 'package:provider/provider.dart';

class AttendancePercentageScreen extends StatefulWidget {
  static const String page = 'AttendancePercentageScreen';

  const AttendancePercentageScreen({super.key});

  @override
  State<AttendancePercentageScreen> createState() =>
      _AttendancePercentageScreenState();
}

class _AttendancePercentageScreenState
    extends State<AttendancePercentageScreen> {
  final AppPreferences _appPreferences = AppPreferences();

  // Common state
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  String? errorMessage;
  UserType? userType;

  // Teacher-specific state
  List<Map<String, dynamic>> classes = []; // Simple class list
  Map<String, dynamic>? selectedClass;
  Map<String, List<Map<String, dynamic>>> attendanceCache =
      {}; // {classId: [students]}

  // Parent-specific state
  List<Map<String, dynamic>> children = []; // List of child attendance data

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
      await _loadClassesList();
    } else if (userType == UserType.PARENT) {
      await _loadParentAttendanceData();
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

  Future<void> _loadClassesList() async {
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
        _parseClassesList(response);
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load classes: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _parseClassesList(Map<String, dynamic> response) {
    final message = response['message'] as Map<String, dynamic>?;
    if (message == null) return;

    // Extract academic year
    if (message['acad_year'] != null) {
      final acadYear = message['acad_year'] as String;
      final parts = acadYear.split('|');
      if (parts.length == 2) {
        academicYearStart = _parseDate(parts[0]);
        academicYearEnd = _parseDate(parts[1]);
      }
    }

    // Parse classes from the classes object - structure: {classId: {hr_name, division, ...}}
    final classesData = message['classes'] as Map<String, dynamic>?;

    if (classesData != null) {
      final classesList = <Map<String, dynamic>>[];

      classesData.forEach((classIdStr, classDetails) {
        if (classDetails is Map<String, dynamic>) {
          final hrName = classDetails['hr_name'] ?? '';
          final division = classDetails['division'] ?? '';
          final className = '$hrName $division'.trim();

          classesList.add({
            'class_detail_id': int.tryParse(classIdStr) ?? 0,
            'class_name': className,
          });
        }
      });

      setState(() {
        classes = classesList;
      });
    }
  }

  Future<void> _loadClassAttendanceData(Map<String, dynamic> classData) async {
    final classId = classData['class_detail_id'].toString();

    // Check if already cached
    if (attendanceCache.containsKey(classId)) {
      return;
    }

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

      final response = await AttendanceService.getAttendancePercentage(
        apiToken: apiToken,
        fromDate:
            academicYearStart ??
            DateTime.now().subtract(const Duration(days: 365)),
        toDate: academicYearEnd ?? DateTime.now(),
        classDetailId: classData['class_detail_id'],
      );

      if (AttendanceService.isValidResponse(response)) {
        _parseClassAttendanceData(response, classId);
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load attendance data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _parseClassAttendanceData(
    Map<String, dynamic> response,
    String classId,
  ) {
    final message = response['message'] as Map<String, dynamic>?;
    if (message == null) return;

    final classesData = message['classes'] as Map<String, dynamic>?;
    if (classesData != null && classesData[classId] != null) {
      final classData = classesData[classId] as Map<String, dynamic>;
      final studentsData = classData['students'] as List<dynamic>? ?? [];

      setState(() {
        attendanceCache[classId] = studentsData.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _loadParentAttendanceData() async {
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

      final response = await AttendanceService.getParentAttendancePercentage(
        apiToken,
      );

      if (AttendanceService.isValidResponse(response)) {
        _parseParentAttendanceData(response);
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load attendance data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _parseParentAttendanceData(Map<String, dynamic> response) {
    final message = response['message'] as Map<String, dynamic>?;
    if (message == null) return;

    // Extract academic year
    if (message['acad_year'] != null) {
      final acadYear = message['acad_year'] as String;
      final parts = acadYear.split('|');
      if (parts.length == 2) {
        academicYearStart = _parseDate(parts[0]);
        academicYearEnd = _parseDate(parts[1]);
      }
    }

    // Parse children data directly
    final childrenData = message['children'] as Map<String, dynamic>?;
    if (childrenData != null) {
      final childrenList = <Map<String, dynamic>>[];

      childrenData.forEach((childIdStr, childData) {
        if (childData is Map<String, dynamic>) {
          final enrichedChildData = Map<String, dynamic>.from(childData);
          enrichedChildData['user_id'] = int.tryParse(childIdStr) ?? 0;
          childrenList.add(enrichedChildData);
        }
      });

      setState(() {
        children = childrenList;
      });
    }
  }

  void _onClassChanged(Map<String, dynamic>? newClass) {
    if (newClass != null && newClass != selectedClass) {
      setState(() {
        selectedClass = newClass;
      });
      // Load attendance data for this class
      _loadClassAttendanceData(newClass);
    }
  }

  double _getAttendancePercentage(Map<String, dynamic> data) {
    // Handle different API response structures based on user type
    num presentDays;
    num totalDays;

    if (userType == UserType.PARENT) {
      // Parent API: present_days / marked_days
      presentDays = (data['present_days'] ?? 0) as num;
      totalDays = (data['marked_days'] ?? 0) as num;
    } else {
      // Teacher/Admin API: total_present_days / total_attendance_days
      presentDays = (data['total_present_days'] ?? 0) as num;
      totalDays = (data['total_attendance_days'] ?? 0) as num;
    }

    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }

  Widget _buildStudentAttendanceCard(
    Map<String, dynamic> studentData,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final percentage = _getAttendancePercentage(studentData);

    // Extract attendance data based on user type
    num presentDays;
    num totalDays;

    if (userType == UserType.PARENT) {
      // Parent API: present_days / marked_days
      presentDays = (studentData['present_days'] ?? 0) as num;
      totalDays = (studentData['marked_days'] ?? 0) as num;
    } else {
      // Teacher/Admin API: total_present_days / total_attendance_days
      presentDays = (studentData['total_present_days'] ?? 0) as num;
      totalDays = (studentData['total_attendance_days'] ?? 0) as num;
    }

    // Extract student info from the data
    final firstName = studentData['first_name'] ?? '';
    final middleName = studentData['middle_name'] ?? '';
    final lastName = studentData['last_name'] ?? '';
    final fullName = '$firstName $middleName $lastName'.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    final photoUrl = studentData['photo_url'] ?? '';
    final genderId = studentData['gender_id'] ?? 0;

    return Container(
      key: Key('attendanceStudentCard_${studentData['user_id'] ?? ''}'),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha((255 * 0.1).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          StudentAvatar(
            firstName: firstName,
            lastName: lastName,
            photoUrl: photoUrl,
            genderId: genderId,
            radius: 21,
          ),
          const SizedBox(width: 16),

          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.daysPresent(presentDays.toInt(), totalDays.toInt()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Percentage
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection(AppLocalizations l10n, ThemeData theme) {
    if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
      return _buildClassDropdown(l10n, theme);
    }
    // No dropdown for parents - they see all children at once
    return const SizedBox.shrink();
  }

  Widget _buildClassDropdown(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectClass,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12.0),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              key: const Key('attendanceClassDropdown'),
              value: selectedClass,
              hint: Text(l10n.selectAClass),
              onChanged: _onClassChanged,
              items: classes.map<DropdownMenuItem<Map<String, dynamic>>>((
                Map<String, dynamic> classData,
              ) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: classData,
                  child: Text(classData['class_name'] ?? l10n.unknownClass),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PetraCalendar(
        selectedDate: selectedDate,
        selectionMode: CalendarSelectionMode.single,
        showSelectedDateIndicator: true,
        minDate: selectedDate, // Only current date selectable
        maxDate: selectedDate, // Only current date selectable
        onDateChanged: (DateTime date) {
          // Do nothing - date is not changeable
        },
      ),
    );
  }

  Widget _buildResultsSection(AppLocalizations l10n, ThemeData theme) {
    if (userType == UserType.TEACHER || userType == UserType.ADMIN) {
      return _buildTeacherResults(l10n, theme);
    } else if (userType == UserType.PARENT) {
      return _buildParentResults(l10n, theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTeacherResults(AppLocalizations l10n, ThemeData theme) {
    if (selectedClass == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pleaseSelectClassFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final classIdStr = selectedClass!['class_detail_id'].toString();
    final studentsData = attendanceCache[classIdStr] ?? [];

    if (studentsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No students found for this class',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: studentsData.length,
      itemBuilder: (context, index) {
        final studentData = studentsData[index];
        return _buildStudentAttendanceCard(studentData, l10n, theme);
      },
    );
  }

  Widget _buildParentResults(AppLocalizations l10n, ThemeData theme) {
    if (children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // For parents, show all children at once - no dropdown needed
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final childData = children[index];
        return _buildStudentAttendanceCard(childData, l10n, theme);
      },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                  // Calendar Section
                  _buildCalendarSection(l10n, theme),

                  // Dropdown Section (Class or Child)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: _buildDropdownSection(l10n, theme),
                  ),

                  const SizedBox(height: 24),

                  // Results Section
                  Expanded(child: _buildResultsSection(l10n, theme)),
                ],
              ),
      ),
    );
  }
}
