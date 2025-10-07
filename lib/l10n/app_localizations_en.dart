// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get drawerHomeMenuTitle => 'Home';

  @override
  String get welcomeMessage =>
      'Enabling schools to guide the diamonds of tomorrow for a better future';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginButton => 'Login';

  @override
  String get loginFailedMessage => 'Login failed. Please try again.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get usernameRequiredError => 'Please enter your username';

  @override
  String get passwordRequiredError => 'Please enter your password';

  @override
  String get registerButton => 'Register';

  @override
  String get switchSchoolButton => 'Switch school';

  @override
  String get registrationNotImplemented => 'Registration not implemented yet';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationPermissionMessage =>
      'Please enable notifications for the app to work properly.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateMessage =>
      'Please update the app to the latest version for the best experience.';

  @override
  String get update => 'Update';

  @override
  String get enterSchoolCodeTitle => 'Enter school code';

  @override
  String get schoolCodeLabel => 'School Code';

  @override
  String get schoolCodeRequiredError => 'School code is required.';

  @override
  String get submitButton => 'Submit';

  @override
  String get invalidSchoolCode => 'Invalid school code.';

  @override
  String get notAPartOfFamilyText => 'Not a part of the Petrasoft family yet ?';

  @override
  String get dayDetailsTitle => 'Day Details';

  @override
  String get joinUsTodayButton => 'Join us today';

  @override
  String get petrasoftSolutionsText => 'Petrasoft Solutions';

  @override
  String get errorValidatingCode => 'Error validating code. Please try again.';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get drawerSchoolCodeTitle => 'School Code';

  @override
  String get drawerAboutTitle => 'About';

  @override
  String get drawerErrorTitle => 'Error';

  @override
  String get loadingText => 'Loading...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeText => 'Theme';

  @override
  String get lightModeText => 'Light Mode';

  @override
  String get darkModeText => 'Dark Mode';

  @override
  String get preferencesText => 'Preferences';

  @override
  String get notificationsText => 'Notifications';

  @override
  String get languageText => 'Language';

  @override
  String get informationText => 'Information';

  @override
  String get aboutUsText => 'About Us';

  @override
  String get privacyPolicyText => 'Privacy Policy';

  @override
  String get getHelpText => 'Get Help';

  @override
  String get accountText => 'Account';

  @override
  String get switchSchoolText => 'Switch School';

  @override
  String get signOutText => 'Sign Out';

  @override
  String get languageHumanReadableName => 'English';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome $name';
  }

  @override
  String get markAttendanceText => 'Mark\nAttendance';

  @override
  String get reviewAttendanceText => 'Review\nAttendance';

  @override
  String get attendancePercentageText => 'Attendance\nPercentage';

  @override
  String get markAttendanceTitle => 'Mark Attendance';

  @override
  String get reviewAttendanceTitle => 'Review Attendance';

  @override
  String get attendancePercentageTitle => 'Attendance Percentage';

  @override
  String get noticeBoardText => 'Notice\nBoard';

  @override
  String get busTrackingText => 'Bus\nTracking';

  @override
  String get calendarText => 'Calendar';

  @override
  String get month => 'Month';

  @override
  String get selectClass => 'Select Class';

  @override
  String get noClassesAvailable => 'No classes available';

  @override
  String get pleaseLoginAgain => 'Please login again';

  @override
  String get failedToLoadClasses => 'Failed to load classes. Please try again.';

  @override
  String get errorLoadingClasses => 'Error loading classes';

  @override
  String get pleaseSelectClassFirst => 'Please select a class first';

  @override
  String get noStudentsFoundInClass => 'No students found in this class';

  @override
  String notWorkingDayFor(String className) {
    return 'Today is not a working day for $className';
  }

  @override
  String get attendanceAlreadyMarked => 'Attendance Already Marked';

  @override
  String attendanceAlreadyMarkedFor(String className) {
    return 'Attendance has already been marked for $className today. If you need to make changes, please use the web interface.';
  }

  @override
  String get viewHistoricalAttendance => 'View Historical Attendance';

  @override
  String get selectDate => 'Select Date';

  @override
  String studentsCount(int count) {
    return 'Students ($count)';
  }

  @override
  String presentCount(int count) {
    return 'Present: $count';
  }

  @override
  String absentCount(int count) {
    return 'Absent: $count';
  }

  @override
  String get considerAddingRemarksForAbsent =>
      'Consider adding remarks for absent students';

  @override
  String get canAddRemarksForAnyStudent =>
      'You can add remarks for any student as needed';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get remark => 'Remark';

  @override
  String get tapToAddRemark => 'Tap to add remark...';

  @override
  String get confirmAttendance => 'Confirm Attendance';

  @override
  String markStudentAs(String studentName, String status) {
    return 'Mark $studentName as $status?';
  }

  @override
  String get canAddRemarkForStudent => 'You can add a remark for this student';

  @override
  String get markPresent => 'Mark Present';

  @override
  String get markAbsent => 'Mark Absent';

  @override
  String get addRemark => 'Add Remark';

  @override
  String studentLabel(String studentName) {
    return 'Student: $studentName';
  }

  @override
  String get enterRemarkForStudent => 'Enter remark for this student...';

  @override
  String get save => 'Save';

  @override
  String get attendanceMarkedSuccessfully => 'Attendance marked successfully!';

  @override
  String get attendanceInfoNotAvailable =>
      'Attendance information is not available';

  @override
  String get selectChild => 'Select Child';

  @override
  String attendanceMarkedWithRemarks(int count) {
    return 'Attendance marked successfully! ($count remarks saved)';
  }

  @override
  String get attendanceAlreadyMarkedToday =>
      'Attendance has already been marked for this class today';

  @override
  String get notWorkingDayForClass =>
      'Today is not a working day for this class';

  @override
  String get markAttendance => 'Mark Attendance';

  @override
  String get notWorkingDay => 'Not a Working Day';

  @override
  String get saving => 'Saving...';

  @override
  String get failedToSaveAttendance => 'Failed to save attendance';

  @override
  String get cannotMarkAttendanceNonWorking =>
      'Cannot mark attendance on a non-working day';

  @override
  String get canAddRemarksAsNeeded =>
      'You can add remarks for any student as needed';

  @override
  String get todayNotWorkingDayClass =>
      'Today is not a working day for this class';

  @override
  String get attendanceAlreadyMarkedButton => 'Attendance Already Marked';

  @override
  String get notWorkingDayButton => 'Not a Working Day';

  @override
  String get markAttendanceButton => 'Mark Attendance';

  @override
  String rollNumber(String rollNo) {
    return 'Roll No: $rollNo';
  }

  @override
  String admissionNumber(String admissionNo) {
    return 'Admission No: $admissionNo';
  }

  @override
  String fatherName(String fatherName) {
    return 'Father: $fatherName';
  }

  @override
  String get authTokenNotFound => 'Authentication token not found';

  @override
  String get attendanceAlreadyMarkedForClassToday =>
      'Attendance has already been marked for this class today';

  @override
  String attendanceMarkedSuccessfullyWithRemarks(int count) {
    return 'Attendance marked successfully! ($count remarks saved)';
  }

  @override
  String get markText => 'Mark';

  @override
  String get asText => 'as';

  @override
  String get questionMark => '?';

  @override
  String get todayNotWorkingDayForClass =>
      'Today is not a working day for this class';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get remarks => 'Remarks';

  @override
  String get classLabel => 'Class';

  @override
  String get studentId => 'Student ID';

  @override
  String get failedToLoadChildren => 'Failed to load children';

  @override
  String get failedToLoadAttendanceRecords =>
      'Failed to load attendance records';

  @override
  String get failedToLoadAttendanceData => 'Failed to load attendance data';

  @override
  String get authenticationTokenNotFound => 'Authentication token not found';

  @override
  String daysPresent(int present, int total) {
    return '$present/$total days present';
  }

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get address => 'Address';

  @override
  String get email => 'Email';

  @override
  String get phoneNumbers => 'Phone Numbers';

  @override
  String get petrasoftSolutions => 'Petrasoft Solutions';

  @override
  String get selectAClass => 'Select a class';

  @override
  String get unknownClass => 'Unknown Class';

  @override
  String get couldNotOpenAppSettings => 'Could not open app settings';

  @override
  String get sunday => 'Sun';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarDayDetailsPlaceholder => 'Select a date to view details';

  @override
  String get calendarHolidayLabel => 'Holiday';

  @override
  String get calendarWorkingDayLabel => 'Working Day';

  @override
  String calendarLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get calendarLoadError =>
      'Failed to load calendar data. Please try again.';

  @override
  String get notices => 'Notices';

  @override
  String get noNotices => 'No notices available';

  @override
  String get category => 'Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noNoticesInCategory => 'No notices in this category';

  @override
  String get newLabel => 'New';

  @override
  String get retry => 'Try Again';

  @override
  String get attendanceAlertTitle => 'Attendance Alert';

  @override
  String get attendanceAlertStudent => 'Student';

  @override
  String get attendanceAlertMarkedBy => 'Marked by';

  @override
  String get attendanceAlertMarkedTime => 'Time';

  @override
  String get attendanceAlertNoData => 'No attendance alert data available';

  @override
  String get reviewAttendanceButton => 'Review Attendance';

  @override
  String get refreshCalendarTooltip => 'Refresh Calendar';

  @override
  String get regularWorkingDay => 'Regular working day';

  @override
  String get reasonLabel => 'Reason: ';
}
