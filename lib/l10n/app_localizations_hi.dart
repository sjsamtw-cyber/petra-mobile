// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get drawerHomeMenuTitle => 'घर';

  @override
  String get welcomeMessage =>
      'स्कूलों को कल के हीरों का मार्गदर्शन करने में सक्षम बना रहे हैं एक बेहतर भविष्य के लिए';

  @override
  String get loginTitle => 'लॉगिन';

  @override
  String get loginButton => 'लॉगिन करें';

  @override
  String get loginFailedMessage => 'लॉगिन विफल। कृपया पुन: प्रयास करें।';

  @override
  String get usernameLabel => 'उपयोगकर्ता नाम';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get usernameRequiredError => 'कृपया अपना उपयोगकर्ता नाम दर्ज करें';

  @override
  String get passwordRequiredError => 'कृपया अपना पासवर्ड दर्ज करें';

  @override
  String get registerButton => 'पंजीकरण करें';

  @override
  String get switchSchoolButton => 'स्कूल बदलें';

  @override
  String get registrationNotImplemented => 'पंजीकरण अभी लागू नहीं किया गया है';

  @override
  String get enableNotifications => 'सूचनाएं सक्षम करें';

  @override
  String get notificationPermissionMessage =>
      'कृपया ऐप को सही ढंग से काम करने के लिए सूचनाएं सक्षम करें।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get updateMessage =>
      'कृपया सर्वोत्तम अनुभव के लिए ऐप को नवीनतम संस्करण में अपडेट करें।';

  @override
  String get update => 'अपडेट करें';

  @override
  String get enterSchoolCodeTitle => 'स्कूल कोड दर्ज करें';

  @override
  String get schoolCodeLabel => 'स्कूल कोड';

  @override
  String get schoolCodeRequiredError => 'स्कूल कोड आवश्यक है।';

  @override
  String get submitButton => 'जमा करें';

  @override
  String get invalidSchoolCode => 'अमान्य स्कूल कोड।';

  @override
  String get notAPartOfFamilyText =>
      'अभी तक पेट्रासॉफ्ट परिवार का हिस्सा नहीं हैं?';

  @override
  String get dayDetailsTitle => 'दिन का विवरण';

  @override
  String get joinUsTodayButton => 'आज ही हमसे जुड़ें';

  @override
  String get petrasoftSolutionsText => 'पेट्रासॉफ्ट सॉल्यूशंस';

  @override
  String get errorValidatingCode =>
      'कोड सत्यापित करने में त्रुटि। कृपया पुन: प्रयास करें।';

  @override
  String get couldNotOpenLink => 'लिंक नहीं खोल सका।';

  @override
  String get drawerSchoolCodeTitle => 'स्कूल कोड';

  @override
  String get drawerAboutTitle => 'हमारे बारे में';

  @override
  String get drawerErrorTitle => 'त्रुटि';

  @override
  String get loadingText => 'लोड हो रहा है...';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get themeText => 'थीम';

  @override
  String get lightModeText => 'लाइट मोड';

  @override
  String get darkModeText => 'डार्क मोड';

  @override
  String get preferencesText => 'प्राथमिकताएं';

  @override
  String get notificationsText => 'सूचनाएं';

  @override
  String get languageText => 'भाषा';

  @override
  String get informationText => 'जानकारी';

  @override
  String get aboutUsText => 'हमारे बारे में';

  @override
  String get privacyPolicyText => 'गोपनीयता नीति';

  @override
  String get getHelpText => 'सहायता प्राप्त करें';

  @override
  String get accountText => 'खाता';

  @override
  String get switchSchoolText => 'स्कूल बदलें';

  @override
  String get signOutText => 'साइन आउट';

  @override
  String get languageHumanReadableName => 'हिन्दी';

  @override
  String dashboardWelcome(String name) {
    return 'स्वागत $name';
  }

  @override
  String get markAttendanceText => 'उपस्थिति\nअंकित करें';

  @override
  String get reviewAttendanceText => 'उपस्थिति\nसमीक्षा करें';

  @override
  String get attendancePercentageText => 'उपस्थिति\nप्रतिशत';

  @override
  String get markAttendanceTitle => 'उपस्थिति अंकित करें';

  @override
  String get reviewAttendanceTitle => 'उपस्थिति समीक्षा करें';

  @override
  String get attendancePercentageTitle => 'उपस्थिति प्रतिशत';

  @override
  String get noticeBoardText => 'सूचना\nबोर्ड';

  @override
  String get busTrackingText => 'बस\nट्रैकिंग';

  @override
  String get calendarText => 'कैलेंडर';

  @override
  String get month => 'महीना';

  @override
  String get selectClass => 'कक्षा चुनें';

  @override
  String get noClassesAvailable => 'कोई कक्षा उपलब्ध नहीं';

  @override
  String get pleaseLoginAgain => 'कृपया पुनः लॉगिन करें';

  @override
  String get failedToLoadClasses =>
      'कक्षाएं लोड करने में विफल। कृपया पुन: प्रयास करें।';

  @override
  String get errorLoadingClasses => 'कक्षाएं लोड करते समय त्रुटि';

  @override
  String get pleaseSelectClassFirst => 'कृपया पहले एक कक्षा चुनें';

  @override
  String get noStudentsFoundInClass => 'इस कक्षा में कोई छात्र नहीं मिला';

  @override
  String notWorkingDayFor(String className) {
    return 'आज $className के लिए कार्य दिवस नहीं है';
  }

  @override
  String get attendanceAlreadyMarked => 'उपस्थिति पहले से चिह्नित है';

  @override
  String attendanceAlreadyMarkedFor(String className) {
    return '$className के लिए आज की उपस्थिति पहले से चिह्नित है। यदि आपको बदलाव करने की आवश्यकता है, तो कृपया वेब इंटरफेस का उपयोग करें।';
  }

  @override
  String get viewHistoricalAttendance => 'ऐतिहासिक उपस्थिति देखें';

  @override
  String get selectDate => 'दिनांक चुनें';

  @override
  String studentsCount(int count) {
    return 'छात्र ($count)';
  }

  @override
  String presentCount(int count) {
    return 'उपस्थित: $count';
  }

  @override
  String absentCount(int count) {
    return 'अनुपस्थित: $count';
  }

  @override
  String get considerAddingRemarksForAbsent =>
      'अनुपस्थित छात्रों के लिए टिप्पणी जोड़ने पर विचार करें';

  @override
  String get canAddRemarksForAnyStudent =>
      'आप आवश्यकतानुसार किसी भी छात्र के लिए टिप्पणी जोड़ सकते हैं';

  @override
  String get present => 'उपस्थित';

  @override
  String get absent => 'अनुपस्थित';

  @override
  String get remark => 'टिप्पणी';

  @override
  String get tapToAddRemark => 'टिप्पणी जोड़ने के लिए टैप करें...';

  @override
  String get confirmAttendance => 'उपस्थिति की पुष्टि करें';

  @override
  String markStudentAs(String studentName, String status) {
    return '$studentName को $status के रूप में चिह्नित करें?';
  }

  @override
  String get canAddRemarkForStudent =>
      'आप इस छात्र के लिए टिप्पणी जोड़ सकते हैं';

  @override
  String get markPresent => 'उपस्थित चिह्नित करें';

  @override
  String get markAbsent => 'अनुपस्थित चिह्नित करें';

  @override
  String get addRemark => 'टिप्पणी जोड़ें';

  @override
  String studentLabel(String studentName) {
    return 'छात्र: $studentName';
  }

  @override
  String get enterRemarkForStudent => 'इस छात्र के लिए टिप्पणी दर्ज करें...';

  @override
  String get save => 'सहेजें';

  @override
  String get attendanceMarkedSuccessfully =>
      'उपस्थिति सफलतापूर्वक चिह्नित की गई!';

  @override
  String get attendanceInfoNotAvailable => 'उपस्थिति की जानकारी उपलब्ध नहीं है';

  @override
  String get selectChild => 'बच्चे का चयन करें';

  @override
  String attendanceMarkedWithRemarks(int count) {
    return 'उपस्थिति सफलतापूर्वक चिह्नित की गई! ($count टिप्पणियां सहेजी गईं)';
  }

  @override
  String get attendanceAlreadyMarkedToday =>
      'आज इस कक्षा के लिए उपस्थिति पहले से चिह्नित है';

  @override
  String get notWorkingDayForClass => 'आज इस कक्षा के लिए कार्य दिवस नहीं है';

  @override
  String get markAttendance => 'उपस्थिति चिह्नित करें';

  @override
  String get notWorkingDay => 'कार्य दिवस नहीं';

  @override
  String get saving => 'सहेज रहे हैं...';

  @override
  String get failedToSaveAttendance => 'उपस्थिति सहेजने में विफल';

  @override
  String get cannotMarkAttendanceNonWorking =>
      'गैर-कार्य दिवस पर उपस्थिति चिह्नित नहीं की जा सकती';

  @override
  String get canAddRemarksAsNeeded =>
      'आप आवश्यकतानुसार टिप्पणियां जोड़ सकते हैं';

  @override
  String get todayNotWorkingDayClass => 'आज इस कक्षा के लिए कार्य दिवस नहीं है';

  @override
  String get attendanceAlreadyMarkedButton => 'उपस्थिति पहले से मार्क्ड';

  @override
  String get notWorkingDayButton => 'कार्य दिवस नहीं';

  @override
  String get markAttendanceButton => 'उपस्थिति चिह्नित करें';

  @override
  String rollNumber(String rollNo) {
    return 'रोल नं: $rollNo';
  }

  @override
  String admissionNumber(String admissionNo) {
    return 'प्रवेश नं: $admissionNo';
  }

  @override
  String fatherName(String fatherName) {
    return 'पिता: $fatherName';
  }

  @override
  String get authTokenNotFound => 'प्रमाणीकरण टोकन नहीं मिला';

  @override
  String get attendanceAlreadyMarkedForClassToday =>
      'इस कक्षा के लिए आज उपस्थिति पहले से चिह्नित है';

  @override
  String attendanceMarkedSuccessfullyWithRemarks(int count) {
    return 'उपस्थिति सफलतापूर्वक चिह्नित की गई! ($count टिप्पणियां सहेजी गईं)';
  }

  @override
  String get markText => 'मार्क करें';

  @override
  String get asText => 'के रूप में';

  @override
  String get questionMark => '?';

  @override
  String get todayNotWorkingDayForClass =>
      'आज इस कक्षा के लिए कार्य दिवस नहीं है';

  @override
  String get unknownError => 'अज्ञात त्रुटि';

  @override
  String get remarks => 'टिप्पणियाँ';

  @override
  String get classLabel => 'कक्षा';

  @override
  String get studentId => 'छात्र आईडी';

  @override
  String get failedToLoadChildren => 'बच्चों को लोड करने में असफल';

  @override
  String get failedToLoadAttendanceRecords =>
      'उपस्थिति रिकॉर्ड लोड करने में असफल';

  @override
  String get failedToLoadAttendanceData => 'उपस्थिति डेटा लोड करने में असफल';

  @override
  String get authenticationTokenNotFound => 'प्रमाणीकरण टोकन नहीं मिला';

  @override
  String daysPresent(int present, int total) {
    return '$present/$total दिन उपस्थित';
  }

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फरवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get address => 'पता';

  @override
  String get email => 'ईमेल';

  @override
  String get phoneNumbers => 'फोन नंबर';

  @override
  String get petrasoftSolutions => 'पेट्रासॉफ्ट सॉल्यूशंस';

  @override
  String get selectAClass => 'एक कक्षा चुनें';

  @override
  String get unknownClass => 'अज्ञात कक्षा';

  @override
  String get couldNotOpenAppSettings => 'ऐप सेटिंग्स नहीं खोल सका';

  @override
  String get sunday => 'रवि';

  @override
  String get monday => 'सोम';

  @override
  String get tuesday => 'मंगल';

  @override
  String get wednesday => 'बुध';

  @override
  String get thursday => 'गुरु';

  @override
  String get friday => 'शुक्र';

  @override
  String get saturday => 'शनि';

  @override
  String get calendarTitle => 'कैलेंडर';

  @override
  String get calendarDayDetailsPlaceholder =>
      'विवरण देखने के लिए एक तारीख चुनें';

  @override
  String get calendarHolidayLabel => 'छुट्टी';

  @override
  String get calendarWorkingDayLabel => 'कार्य दिवस';

  @override
  String calendarLastUpdated(String date) {
    return 'अंतिम अपडेट: $date';
  }

  @override
  String get calendarLoadError =>
      'कैलेंडर डेटा लोड करने में विफल। कृपया पुन: प्रयास करें।';

  @override
  String get notices => 'सूचनाएं';

  @override
  String get noNotices => 'कोई सूचना उपलब्ध नहीं है';

  @override
  String get category => 'श्रेणी';

  @override
  String get allCategories => 'सभी श्रेणियां';

  @override
  String get noNoticesInCategory => 'इस श्रेणी में कोई सूचना नहीं है';

  @override
  String get newLabel => 'नया';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get attendanceAlertTitle => 'उपस्थिति अलर्ट';

  @override
  String get attendanceAlertStudent => 'छात्र';

  @override
  String get attendanceAlertMarkedBy => 'द्वारा चिह्नित';

  @override
  String get attendanceAlertMarkedTime => 'समय';

  @override
  String get attendanceAlertNoData => 'कोई उपस्थिति अलर्ट डेटा उपलब्ध नहीं है';

  @override
  String get reviewAttendanceButton => 'उपस्थिति की समीक्षा करें';

  @override
  String get refreshCalendarTooltip => 'कैलेंडर रीफ्रेश करें';

  @override
  String get regularWorkingDay => 'नियमित कार्य दिवस';

  @override
  String get reasonLabel => 'कारण: ';
}
