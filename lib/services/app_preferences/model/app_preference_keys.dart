// A central place for storing the keys for shared preferences.
class AppPreferenceKeys {
  static const String isSchoolCodeSet = 'is_school_code_set';
  static const String apiURL = 'api_url';
  static const String appLocale = 'app_locale';
  static const String countryCode = 'country_code';
  static const String user = 'user';
  static const String isDarkModeEnabled = 'is_dark_mode_enabled';
  static const String schoolCode = 'school_code';
  static const String notificationDialogShown = 'notification_dialog_shown';
  static const String updateDialogShown = 'update_dialog_shown';
  static const String userPresent = 'user_present';
  static const String notificationsEnabled = 'notifications_enabled';
}

// A central place for storing constants related to app preferences.
class AppPreferenceConstants {
  static const String firebaseDebugHostAndroid = '10.0.2.2:63421';
  static const String firebaseDebugHostIOS =
      'localhost:63421'; // Will work for web & iOS.
  static const String devDomain = 'https://petra.test';

  // HTTP timeout constants
  static const int httpConnectTimeoutSeconds = 15;
  static const int httpReceiveTimeoutSeconds = 15;
  static const int httpRequestTimeoutSeconds = 15; // For general HTTP requests
}
