import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The title of the drawer home menu
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHomeMenuTitle;

  /// A welcome message displayed on the home screen
  ///
  /// In en, this message translates to:
  /// **'Enabling schools to guide the diamonds of tomorrow for a better future'**
  String get welcomeMessage;

  /// Title for the login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Text for the login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Message displayed when login fails
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailedMessage;

  /// Label for the username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Label for the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Error message when username is not entered
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequiredError;

  /// Error message when password is not entered
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequiredError;

  /// Text for the register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Text for the switch school button
  ///
  /// In en, this message translates to:
  /// **'Switch school'**
  String get switchSchoolButton;

  /// Message when registration is not implemented
  ///
  /// In en, this message translates to:
  /// **'Registration not implemented yet'**
  String get registrationNotImplemented;

  /// Title of the dialog that asks users to enable notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Message explaining why notifications are needed
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications for the app to work properly.'**
  String get notificationPermissionMessage;

  /// Button text to open device settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the dialog that informs about app updates
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// Message explaining why the app should be updated
  ///
  /// In en, this message translates to:
  /// **'Please update the app to the latest version for the best experience.'**
  String get updateMessage;

  /// Button text to trigger app update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Title for the school code entry screen
  ///
  /// In en, this message translates to:
  /// **'Enter school code'**
  String get enterSchoolCodeTitle;

  /// Label for the school code input field
  ///
  /// In en, this message translates to:
  /// **'School Code'**
  String get schoolCodeLabel;

  /// Error message when school code is not entered
  ///
  /// In en, this message translates to:
  /// **'School code is required.'**
  String get schoolCodeRequiredError;

  /// Text for the submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Error message for an invalid school code
  ///
  /// In en, this message translates to:
  /// **'Invalid school code.'**
  String get invalidSchoolCode;

  /// Text displayed above the 'Join us today' button
  ///
  /// In en, this message translates to:
  /// **'Not a part of the Petrasoft family yet ?'**
  String get notAPartOfFamilyText;

  /// Title for the day details view
  ///
  /// In en, this message translates to:
  /// **'Day Details'**
  String get dayDetailsTitle;

  /// Text for the 'Join us today' button
  ///
  /// In en, this message translates to:
  /// **'Join us today'**
  String get joinUsTodayButton;

  /// Text displayed below the company logo
  ///
  /// In en, this message translates to:
  /// **'Petrasoft Solutions'**
  String get petrasoftSolutionsText;

  /// Generic error message when validating school code fails
  ///
  /// In en, this message translates to:
  /// **'Error validating code. Please try again.'**
  String get errorValidatingCode;

  /// Error message when URL cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// The title of the drawer school code menu item
  ///
  /// In en, this message translates to:
  /// **'School Code'**
  String get drawerSchoolCodeTitle;

  /// The title of the drawer about menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAboutTitle;

  /// The title of the drawer error menu item (for testing)
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get drawerErrorTitle;

  /// Text displayed during loading operations
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for theme section in settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeText;

  /// Text for light mode theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightModeText;

  /// Text for dark mode theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeText;

  /// Label for preferences section in settings
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesText;

  /// Label for notifications option in settings
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsText;

  /// Label for language option in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageText;

  /// Label for information section in settings
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationText;

  /// Label for about us option in settings
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsText;

  /// Label for privacy policy option in settings
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyText;

  /// Label for get help option in settings
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get getHelpText;

  /// Label for account section in settings
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountText;

  /// Label for switch school option in settings
  ///
  /// In en, this message translates to:
  /// **'Switch School'**
  String get switchSchoolText;

  /// Label for sign out option in settings
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutText;

  /// Human readable name of the current language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageHumanReadableName;

  /// Welcome message on dashboard with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String dashboardWelcome(String name);

  /// Label for mark attendance button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Mark\nAttendance'**
  String get markAttendanceText;

  /// Label for review attendance button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Review\nAttendance'**
  String get reviewAttendanceText;

  /// Label for attendance percentage button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Attendance\nPercentage'**
  String get attendancePercentageText;

  /// Title for mark attendance page
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendanceTitle;

  /// Title for review attendance page
  ///
  /// In en, this message translates to:
  /// **'Review Attendance'**
  String get reviewAttendanceTitle;

  /// Title for attendance percentage page
  ///
  /// In en, this message translates to:
  /// **'Attendance Percentage'**
  String get attendancePercentageTitle;

  /// Label for notice board button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Notice\nBoard'**
  String get noticeBoardText;

  /// Label for bus tracking button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Bus\nTracking'**
  String get busTrackingText;

  /// Label for calendar button on dashboard
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarText;

  /// Label for month selector in calendar
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Label for class selector dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Class'**
  String get selectClass;

  /// Message when no classes are available
  ///
  /// In en, this message translates to:
  /// **'No classes available'**
  String get noClassesAvailable;

  /// Message when user needs to login again
  ///
  /// In en, this message translates to:
  /// **'Please login again'**
  String get pleaseLoginAgain;

  /// Error message when loading classes fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load classes. Please try again.'**
  String get failedToLoadClasses;

  /// Generic error message for class loading
  ///
  /// In en, this message translates to:
  /// **'Error loading classes'**
  String get errorLoadingClasses;

  /// Message when no class is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a class first'**
  String get pleaseSelectClassFirst;

  /// Message when class has no students
  ///
  /// In en, this message translates to:
  /// **'No students found in this class'**
  String get noStudentsFoundInClass;

  /// Message when today is not a working day
  ///
  /// In en, this message translates to:
  /// **'Today is not a working day for {className}'**
  String notWorkingDayFor(String className);

  /// Message when attendance is already marked
  ///
  /// In en, this message translates to:
  /// **'Attendance Already Marked'**
  String get attendanceAlreadyMarked;

  /// Detailed message when attendance is already marked
  ///
  /// In en, this message translates to:
  /// **'Attendance has already been marked for {className} today. If you need to make changes, please use the web interface.'**
  String attendanceAlreadyMarkedFor(String className);

  /// Button text for viewing historical attendance
  ///
  /// In en, this message translates to:
  /// **'View Historical Attendance'**
  String get viewHistoricalAttendance;

  /// Header for date selection
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Header showing student count
  ///
  /// In en, this message translates to:
  /// **'Students ({count})'**
  String studentsCount(int count);

  /// Count of present students
  ///
  /// In en, this message translates to:
  /// **'Present: {count}'**
  String presentCount(int count);

  /// Count of absent students
  ///
  /// In en, this message translates to:
  /// **'Absent: {count}'**
  String absentCount(int count);

  /// Suggestion to add remarks for absent students
  ///
  /// In en, this message translates to:
  /// **'Consider adding remarks for absent students'**
  String get considerAddingRemarksForAbsent;

  /// Info about adding remarks
  ///
  /// In en, this message translates to:
  /// **'You can add remarks for any student as needed'**
  String get canAddRemarksForAnyStudent;

  /// Label for present status
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// Label for absent status
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// Label for remark field
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// Placeholder text for adding remark
  ///
  /// In en, this message translates to:
  /// **'Tap to add remark...'**
  String get tapToAddRemark;

  /// Title for attendance confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Attendance'**
  String get confirmAttendance;

  /// Confirmation message for marking attendance
  ///
  /// In en, this message translates to:
  /// **'Mark {studentName} as {status}?'**
  String markStudentAs(String studentName, String status);

  /// Info about adding remark in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You can add a remark for this student'**
  String get canAddRemarkForStudent;

  /// Button text for marking present
  ///
  /// In en, this message translates to:
  /// **'Mark Present'**
  String get markPresent;

  /// Button text for marking absent
  ///
  /// In en, this message translates to:
  /// **'Mark Absent'**
  String get markAbsent;

  /// Title for add remark dialog
  ///
  /// In en, this message translates to:
  /// **'Add Remark'**
  String get addRemark;

  /// Label showing student name
  ///
  /// In en, this message translates to:
  /// **'Student: {studentName}'**
  String studentLabel(String studentName);

  /// Placeholder for remark input
  ///
  /// In en, this message translates to:
  /// **'Enter remark for this student...'**
  String get enterRemarkForStudent;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Success message for attendance marking
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully!'**
  String get attendanceMarkedSuccessfully;

  /// Message shown when attendance record is not available for a selected date
  ///
  /// In en, this message translates to:
  /// **'Attendance information is not available'**
  String get attendanceInfoNotAvailable;

  /// Text prompt to select a child from dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChild;

  /// Success message with remark count
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully! ({count} remarks saved)'**
  String attendanceMarkedWithRemarks(int count);

  /// Message when attendance already marked today
  ///
  /// In en, this message translates to:
  /// **'Attendance has already been marked for this class today'**
  String get attendanceAlreadyMarkedToday;

  /// Message when not a working day
  ///
  /// In en, this message translates to:
  /// **'Today is not a working day for this class'**
  String get notWorkingDayForClass;

  /// Button text for marking attendance
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendance;

  /// Button text when not working day
  ///
  /// In en, this message translates to:
  /// **'Not a Working Day'**
  String get notWorkingDay;

  /// Text shown while saving
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Error message when saving fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save attendance'**
  String get failedToSaveAttendance;

  /// Error when trying to mark on non-working day
  ///
  /// In en, this message translates to:
  /// **'Cannot mark attendance on a non-working day'**
  String get cannotMarkAttendanceNonWorking;

  /// Info about adding remarks for any student
  ///
  /// In en, this message translates to:
  /// **'You can add remarks for any student as needed'**
  String get canAddRemarksAsNeeded;

  /// Message when today is not a working day
  ///
  /// In en, this message translates to:
  /// **'Today is not a working day for this class'**
  String get todayNotWorkingDayClass;

  /// Button text when attendance is already marked
  ///
  /// In en, this message translates to:
  /// **'Attendance Already Marked'**
  String get attendanceAlreadyMarkedButton;

  /// Button text for non-working day
  ///
  /// In en, this message translates to:
  /// **'Not a Working Day'**
  String get notWorkingDayButton;

  /// Button text for marking attendance
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendanceButton;

  /// Student roll number display
  ///
  /// In en, this message translates to:
  /// **'Roll No: {rollNo}'**
  String rollNumber(String rollNo);

  /// Student admission number display
  ///
  /// In en, this message translates to:
  /// **'Admission No: {admissionNo}'**
  String admissionNumber(String admissionNo);

  /// Student father name display
  ///
  /// In en, this message translates to:
  /// **'Father: {fatherName}'**
  String fatherName(String fatherName);

  /// Error when authentication token is not found
  ///
  /// In en, this message translates to:
  /// **'Authentication token not found'**
  String get authTokenNotFound;

  /// Message when attendance already marked today
  ///
  /// In en, this message translates to:
  /// **'Attendance has already been marked for this class today'**
  String get attendanceAlreadyMarkedForClassToday;

  /// Success message with remark count
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully! ({count} remarks saved)'**
  String attendanceMarkedSuccessfullyWithRemarks(int count);

  /// Mark text
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get markText;

  /// As text
  ///
  /// In en, this message translates to:
  /// **'as'**
  String get asText;

  /// Question mark
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get questionMark;

  /// Message when today is not a working day
  ///
  /// In en, this message translates to:
  /// **'Today is not a working day for this class'**
  String get todayNotWorkingDayForClass;

  /// Fallback error message when error type is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Label for remarks
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// Label for class
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// Label for student ID
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// Error message for failed to load children
  ///
  /// In en, this message translates to:
  /// **'Failed to load children'**
  String get failedToLoadChildren;

  /// Error message for failed to load attendance records
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance records'**
  String get failedToLoadAttendanceRecords;

  /// Error message for failed to load attendance data
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance data'**
  String get failedToLoadAttendanceData;

  /// Error message for authentication token not found
  ///
  /// In en, this message translates to:
  /// **'Authentication token not found'**
  String get authenticationTokenNotFound;

  /// Days present format
  ///
  /// In en, this message translates to:
  /// **'{present}/{total} days present'**
  String daysPresent(int present, int total);

  /// Month name January
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// Month name February
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// Month name March
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// Month name April
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// Month name May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// Month name June
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// Month name July
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// Month name August
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// Month name September
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// Month name October
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// Month name November
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// Month name December
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// Label for address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Label for email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for phone numbers
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers'**
  String get phoneNumbers;

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'Petrasoft Solutions'**
  String get petrasoftSolutions;

  /// Hint text for class selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Select a class'**
  String get selectAClass;

  /// Fallback text for unknown class name
  ///
  /// In en, this message translates to:
  /// **'Unknown Class'**
  String get unknownClass;

  /// Error message when app settings cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open app settings'**
  String get couldNotOpenAppSettings;

  /// Abbreviated Sunday
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Abbreviated Monday
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Abbreviated Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Abbreviated Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Abbreviated Thursday
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Abbreviated Friday
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Abbreviated Saturday
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Title for the calendar screen
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// Placeholder text when no date is selected in calendar
  ///
  /// In en, this message translates to:
  /// **'Select a date to view details'**
  String get calendarDayDetailsPlaceholder;

  /// Label for holiday days in calendar
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get calendarHolidayLabel;

  /// Label for working days in calendar
  ///
  /// In en, this message translates to:
  /// **'Working Day'**
  String get calendarWorkingDayLabel;

  /// Text showing when calendar was last updated
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String calendarLastUpdated(String date);

  /// Error message when calendar data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar data. Please try again.'**
  String get calendarLoadError;

  /// Title for the notices screen
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get notices;

  /// Message shown when there are no notices to display
  ///
  /// In en, this message translates to:
  /// **'No notices available'**
  String get noNotices;

  /// Label for notice category dropdown
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for showing all notice categories
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// Message shown when a category has no notices
  ///
  /// In en, this message translates to:
  /// **'No notices in this category'**
  String get noNoticesInCategory;

  /// Label shown on new notices
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// Label for retry buttons
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// Title for attendance alert screen
  ///
  /// In en, this message translates to:
  /// **'Attendance Alert'**
  String get attendanceAlertTitle;

  /// Label for student name in attendance alert
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get attendanceAlertStudent;

  /// Label for who marked the attendance
  ///
  /// In en, this message translates to:
  /// **'Marked by'**
  String get attendanceAlertMarkedBy;

  /// Label for when attendance was marked
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get attendanceAlertMarkedTime;

  /// Message shown when no attendance alert data is available
  ///
  /// In en, this message translates to:
  /// **'No attendance alert data available'**
  String get attendanceAlertNoData;

  /// Button text to review attendance details
  ///
  /// In en, this message translates to:
  /// **'Review Attendance'**
  String get reviewAttendanceButton;

  /// Tooltip for the refresh calendar icon button
  ///
  /// In en, this message translates to:
  /// **'Refresh Calendar'**
  String get refreshCalendarTooltip;

  /// Text indicating a regular working day in calendar details
  ///
  /// In en, this message translates to:
  /// **'Regular working day'**
  String get regularWorkingDay;

  /// Label for the holiday reason text
  ///
  /// In en, this message translates to:
  /// **'Reason: '**
  String get reasonLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
