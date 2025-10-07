import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_class.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/services/attendance.service.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/review_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/shared/class_selector_dropdown.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/user_constants.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/student_avatar.dart';

class MarkAttendanceScreen extends StatefulWidget {
  static const String page = 'MarkAttendanceScreen';

  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final AppPreferences _appPreferences = AppPreferences();

  // State variables
  List<PetraClass> _classes = [];
  PetraClass? _selectedClass;
  DateTime _selectedDate = DateTime.now(); // Always start with current date
  bool _isLoadingClasses = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Student attendance tracking
  final Map<int, bool> _attendanceMap = {};
  final Map<int, String> _remarksMap = {};

  /// Helper method to get localized error message
  String _getLocalizedErrorMessage(String errorKey, [String? details]) {
    final localizations = AppLocalizations.of(context)!;

    switch (errorKey) {
      case 'pleaseLoginAgain':
        return localizations.pleaseLoginAgain;
      case 'failedToLoadClasses':
        return localizations.failedToLoadClasses;
      case 'errorLoadingClasses':
        return '${localizations.errorLoadingClasses}: ${details ?? ''}';
      case 'pleaseSelectClassFirst':
        return localizations.pleaseSelectClassFirst;
      case 'attendanceAlreadyMarkedForClassToday':
        return localizations.attendanceAlreadyMarkedForClassToday;
      case 'cannotMarkAttendanceNonWorking':
        return localizations.cannotMarkAttendanceNonWorking;
      case 'authTokenNotFound':
        return localizations.authTokenNotFound;
      case 'failedToSaveAttendance':
        return '${localizations.failedToSaveAttendance}: ${details ?? ''}';
      default:
        return details ?? localizations.unknownError;
    }
  }

  /// Helper method to get localized success message
  String _getLocalizedSuccessMessage(int remarksCount) {
    final localizations = AppLocalizations.of(context)!;

    return remarksCount > 0
        ? localizations.attendanceMarkedWithRemarks(remarksCount)
        : localizations.attendanceMarkedSuccessfully;
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _errorMessage = null;
    });

    try {
      final apiToken = _appPreferences.fetchStringSharedPref(
        UserPreferenceKeys.apiTokenKey,
      );

      if (kDebugMode) {
        print('Debug: API Token exists: ${apiToken != null}');
        if (apiToken != null) {
          print('Debug: API Token length: ${apiToken.length}');
          print(
            'Debug: API Token first 20 chars: ${apiToken.substring(0, math.min(20, apiToken.length))}...',
          );
        }
      }

      if (apiToken == null) {
        setState(() {
          _isLoadingClasses = false;
          _errorMessage = _getLocalizedErrorMessage('pleaseLoginAgain');
        });
        return;
      }

      if (kDebugMode) {
        print('Debug: Calling AttendanceService.getTeacherClasses...');
      }

      final response = await AttendanceService.getTeacherClasses(apiToken);

      if (kDebugMode) {
        print('Debug: Full API Response: $response');
        print('Debug: Response keys: ${response.keys.toList()}');
        print('Debug: Response status_code: ${response['status_code']}');
        print(
          'Debug: Response message type: ${response['message']?.runtimeType}',
        );
      }

      if (AttendanceService.isValidResponse(response)) {
        final classes = AttendanceService.parseClassesFromResponse(response);

        if (kDebugMode) {
          print('Debug: Parsed ${classes.length} classes');
        }
        for (int i = 0; i < classes.length; i++) {
          if (kDebugMode) {
            print(
              'Debug: Class $i - ${classes[i].className} has ${classes[i].students.length} students',
            );
          }
          for (int j = 0; j < classes[i].students.length; j++) {
            final student = classes[i].students[j];
            if (kDebugMode) {
              print(
                'Debug: Student $j - ${student.fullName} (ID: ${student.studentDetailId})',
              );
            }
          }
        }

        setState(() {
          _classes = classes;
          _isLoadingClasses = false;
          if (classes.isNotEmpty) {
            _selectedClass = classes.first;
            _initializeAttendanceForClass();
          }
        });
      } else {
        if (kDebugMode) {
          print(
            'Debug: Invalid response - status_code: ${response['status_code']}',
          );
          print('Debug: Response message: ${response['message']}');
        }
        setState(() {
          _isLoadingClasses = false;
          _errorMessage = _getLocalizedErrorMessage('failedToLoadClasses');
        });

        // API returned invalid response - no fallback needed since backend works
      }
    } catch (e) {
      if (kDebugMode) {
        print('Debug: Exception in _loadClasses: $e');
        print('Debug: Exception type: ${e.runtimeType}');
        print('Debug: Stack trace: ${StackTrace.current}');
      }
      setState(() {
        _isLoadingClasses = false;
        _errorMessage = _getLocalizedErrorMessage(
          'errorLoadingClasses',
          e.toString(),
        );
      });
    }
  }

  void _onClassChanged(PetraClass? selectedClass) {
    setState(() {
      _selectedClass = selectedClass;
      _errorMessage = null; // Clear any existing errors when class changes
      _initializeAttendanceForClass();
    });
  }

  void _onDateChanged(DateTime date) {
    // Only allow current date when marking attendance
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (isToday) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _initializeAttendanceForClass() {
    if (_selectedClass == null) {
      if (kDebugMode) {
        print('Debug: _initializeAttendanceForClass - No selected class');
      }
      return;
    }
    if (kDebugMode) {
      print(
        'Debug: _initializeAttendanceForClass - Class: ${_selectedClass!.className}',
      );
      print(
        'Debug: _initializeAttendanceForClass - Students count: ${_selectedClass!.students.length}',
      );
      final isAttendanceTaken =
          _selectedClass!.petraDay?.isAttendanceTaken ?? false;
      print('Debug: Attendance already taken: $isAttendanceTaken');
    }

    // Clear existing data
    _attendanceMap.clear();
    _remarksMap.clear();

    // Only initialize attendance data if attendance is not already taken
    // When attendance is already taken, we'll just show the "already marked" message
    if (!_isAttendanceAlreadyTaken) {
      for (final student in _selectedClass!.students) {
        // Default all students to present for new attendance marking
        _attendanceMap[student.studentDetailId] = true;
        _remarksMap[student.studentDetailId] = '';

        if (kDebugMode) {
          print(
            'Debug: Initialized attendance for ${student.fullName} (ID: ${student.studentDetailId}) - Status: true (default)',
          );
        }
      }

      if (kDebugMode) {
        print('Debug: _attendanceMap has ${_attendanceMap.length} entries');
      }
    } else {
      if (kDebugMode) {
        print('Debug: Attendance already taken, skipping initialization');
      }
    }
  }

  void _toggleStudentAttendance(int studentId, bool isPresent) {
    setState(() {
      _attendanceMap[studentId] = isPresent;
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedClass == null) {
      setState(() {
        _errorMessage = _getLocalizedErrorMessage('pleaseSelectClassFirst');
      });
      return;
    }

    // Check if attendance is already taken
    if (_isAttendanceAlreadyTaken) {
      setState(() {
        _errorMessage = _getLocalizedErrorMessage(
          'attendanceAlreadyMarkedForClassToday',
        );
      });
      return;
    }

    // Check if it's a working day
    if (!_isWorkingDay) {
      setState(() {
        _errorMessage = _getLocalizedErrorMessage(
          'cannotMarkAttendanceNonWorking',
        );
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final apiToken = _appPreferences.fetchStringSharedPref(
        UserPreferenceKeys.apiTokenKey,
      );
      if (apiToken == null) {
        throw Exception(_getLocalizedErrorMessage('authTokenNotFound'));
      }

      // Prepare student data with attendance status
      final updatedStudents = _selectedClass!.students.map((student) {
        return student.copyWith(
          attendanceStatus: _attendanceMap[student.studentDetailId] ?? true,
          remarks: _remarksMap[student.studentDetailId] ?? '',
        );
      }).toList();

      final response = await AttendanceService.markAttendance(
        apiToken: apiToken,
        classDetailId: _selectedClass!.classDetailID,
        date: _selectedDate,
        students: updatedStudents,
      );

      if (AttendanceService.isValidResponse(response)) {
        if (mounted) {
          final remarksCount = _remarksMap.values
              .where((remark) => remark.isNotEmpty)
              .length;
          final message = _getLocalizedSuccessMessage(remarksCount);

          // Update the class to reflect attendance has been taken
          // This prevents multiple submissions
          if (_selectedClass!.petraDay != null) {
            final updatedPetraDay = _selectedClass!.petraDay!.copyWith(
              isAttendanceTaken: true,
            );
            // Update the selected class with the new PetraDay state
            final updatedClass = _selectedClass!.copyWith(
              petraDay: updatedPetraDay,
            );

            // Update both the selected class and the classes list
            setState(() {
              _selectedClass = updatedClass;
              // Update the class in the classes list as well
              final classIndex = _classes.indexWhere(
                (cls) => cls.classDetailID == _selectedClass!.classDetailID,
              );
              if (classIndex != -1) {
                _classes[classIndex] = updatedClass;
              }
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navigate to historical attendance screen after successful marking
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushNamed(ReviewAttendanceScreen.page);
            }
          });
        }
      } else {
        throw Exception(AttendanceService.getErrorMessage(response));
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getLocalizedErrorMessage(
          'failedToSaveAttendance',
          e.toString(),
        );
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Shows a confirmation dialog when attendance status is toggled
  Future<void> _showAttendanceConfirmation(student, bool newValue) async {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                newValue ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: newValue
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.confirmAttendance,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(text: '${localizations.markText} '),
                    TextSpan(
                      text: student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' ${localizations.asText} '),
                    TextSpan(
                      text: newValue
                          ? localizations.present
                          : localizations.absent,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: newValue
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                    TextSpan(text: localizations.questionMark),
                  ],
                ),
              ),
              if (!newValue) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.canAddRemarkForStudent,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newValue
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                foregroundColor: newValue
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                newValue ? localizations.markPresent : localizations.markAbsent,
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _toggleStudentAttendance(student.studentDetailId, newValue);
    }
  }

  /// Shows a dialog to add or edit remarks for a student
  Future<void> _showRemarkDialog(student) async {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController remarkController = TextEditingController(
      text: _remarksMap[student.studentDetailId] ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.note_add_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.addRemark,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.studentLabel(student.fullName),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarkController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: localizations.remark,
                  hintText: localizations.enterRemarkForStudent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  labelStyle: TextStyle(color: theme.colorScheme.primary),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(remarkController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _remarksMap[student.studentDetailId] = result;
      });
    }
  }

  /// Check if attendance is already taken for the selected class
  bool get _isAttendanceAlreadyTaken {
    return _selectedClass?.petraDay?.isAttendanceTaken ?? false;
  }

  /// Check if it's a working day for the selected class
  bool get _isWorkingDay {
    return _selectedClass?.petraDay?.isWorkingDay ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error Message Display
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Calendar Section
            _buildCalendarSection(theme, localizations),

            const SizedBox(height: 24),

            // Class Selector Section
            _buildClassSelectorSection(theme, localizations),

            const SizedBox(height: 24),

            // Students List Section
            _buildStudentsSection(theme, localizations),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(theme, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return PetraCalendar(
      key: const Key('attendanceDateCalendar'),
      selectedDate: _selectedDate,
      selectionMode: CalendarSelectionMode.currentDateOnly,
      onDateChanged: _onDateChanged,
      showNavigation: true,
      showSelectedDateIndicator: true,
      headerTitle: localizations.selectDate,
      headerIcon: Icons.calendar_today,
    );
  }

  Widget _buildClassSelectorSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  localizations.selectClass,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoadingClasses)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else if (_classes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                key: const Key('noClassesContainer'),
                child: Center(
                  child: Text(
                    localizations.noClassesAvailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ClassSelectorDropdown(
                classes: _classes,
                selectedClass: _selectedClass,
                onClassChanged: _onClassChanged,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    if (_selectedClass == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.pleaseSelectClassFirst,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedClass!.students.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noStudentsFoundInClass,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if it's not a working day
    if (!_isWorkingDay) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.notWorkingDayFor(_selectedClass!.className),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if attendance is already taken
    if (_isAttendanceAlreadyTaken) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.attendanceAlreadyMarked,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.attendanceAlreadyMarkedFor(
                  _selectedClass!.className,
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Review Attendance Button
              ElevatedButton.icon(
                key: const Key('reviewAttendanceButton'),
                onPressed: () {
                  Navigator.of(context).pushNamed(ReviewAttendanceScreen.page);
                },
                icon: const Icon(Icons.edit_calendar),
                label: Text(localizations.reviewAttendanceTitle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Students Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.studentsCount(
                        _selectedClass!.students.length,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        localizations.presentCount(
                          _attendanceMap.values
                              .where((status) => status)
                              .length,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        localizations.absentCount(
                          _attendanceMap.values
                              .where((status) => !status)
                              .length,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_attendanceMap.values.where((status) => !status).isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            localizations.considerAddingRemarksForAbsent,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            localizations.canAddRemarksForAnyStudent,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Students List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: _selectedClass!.students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = _selectedClass!.students[index];
              final isPresent = _attendanceMap[student.studentDetailId] ?? true;

              return Container(
                key: Key('studentAttendanceCard_${student.studentDetailId}'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPresent
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Student Avatar
                        StudentAvatar(
                          firstName: student.firstName,
                          lastName: student.lastName,
                          photoUrl: student.imageUrl,
                          genderId: student.gender?.index == 0
                              ? 1
                              : 2, // Convert UserGender enum to int
                          radius: 24,
                        ),
                        const SizedBox(width: 16),

                        // Student Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Conditionally show student details if they exist
                              ...(_buildStudentDetails(
                                student,
                                theme,
                                localizations,
                              )),
                            ],
                          ),
                        ),

                        // Attendance Status
                        Column(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Switch(
                                value: isPresent,
                                onChanged: (value) {
                                  _showAttendanceConfirmation(student, value);
                                },
                                activeColor: theme.colorScheme.primary,
                                activeTrackColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                inactiveThumbColor: theme.colorScheme.outline,
                                inactiveTrackColor: theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            Text(
                              isPresent
                                  ? localizations.present
                                  : localizations.absent,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isPresent
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Remark Section - Always show for all students
                    const SizedBox(height: 12),
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
                          Row(
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                localizations.remark,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showRemarkDialog(student),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_remarksMap[student.studentDetailId]?.isEmpty !=
                              false)
                            GestureDetector(
                              onTap: () => _showRemarkDialog(student),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      localizations.tapToAddRemark,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Text(
                              _remarksMap[student.studentDetailId]!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds a list of student detail widgets conditionally based on available data
  List<Widget> _buildStudentDetails(
    student,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final List<Widget> details = [];

    // Show roll number if it exists
    if (student.rollNo != null) {
      details.add(
        Text(
          localizations.rollNumber(student.rollNo.toString()),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Show admission number if it exists and is not empty
    if (student.admissionNumber != null &&
        student.admissionNumber!.isNotEmpty) {
      details.add(
        Text(
          localizations.admissionNumber(student.admissionNumber!),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Show father's name if it exists and is not empty
    if (student.fatherFullName.isNotEmpty) {
      details.add(
        Text(
          localizations.fatherName(student.fatherFullName),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return details;
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations localizations) {
    final isDisabled =
        _isSaving ||
        _selectedClass == null ||
        _isAttendanceAlreadyTaken ||
        !_isWorkingDay;

    return Center(
      child: Column(
        children: [
          // Show appropriate message when button is disabled
          if (!_isWorkingDay)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.todayNotWorkingDayForClass,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ElevatedButton(
            key: const Key('saveAttendanceButton'),
            onPressed: isDisabled ? null : _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              foregroundColor: isDisabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
                vertical: 14.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              minimumSize: const Size(200, 48),
            ),
            child: _isSaving
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.saving,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _isAttendanceAlreadyTaken
                        ? localizations.attendanceAlreadyMarkedButton
                        : !_isWorkingDay
                        ? localizations.notWorkingDayButton
                        : localizations.markAttendanceButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDisabled
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
