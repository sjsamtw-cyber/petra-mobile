import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * Application Preferences
 * - Shared Preferences is just one type of App Preferences
 */

class AppPreferences extends ChangeNotifier {
  late String firestoreDebugHost;
  // The static instance below is not meant to be accessible from outside.
  static AppPreferences? instance;

  // App preferences wraps shared preferences, so that will be a property
  late SharedPreferences sharedPreferences;

  /* Application Preferences based on some external arguments, we can accept
   * those arguments as parameters in the below function
   */
  static Future<void> init() async {
    instance = AppPreferences._init();
    await instance!.setsharedPreferences();
    await instance!.changeStringSharedPref(AppPreferenceKeys.appLocale, 'en');
    await instance!.changeStringSharedPref(AppPreferenceKeys.countryCode, 'IN');
    await instance!.changeBooleanSharedPref(
      AppPreferenceKeys.isDarkModeEnabled,
      false,
    );
    // Initialize notification and update dialog flags to false so they show at least once
    await instance!.changeBooleanSharedPref(
      AppPreferenceKeys.notificationDialogShown,
      false,
    );
    await instance!.changeBooleanSharedPref(
      AppPreferenceKeys.updateDialogShown,
      false,
    );
  }

  AppPreferences._init() {
    firestoreDebugHost = defaultTargetPlatform == TargetPlatform.android
        ? AppPreferenceConstants.firebaseDebugHostAndroid
        : AppPreferenceConstants.firebaseDebugHostIOS;
  }

  factory AppPreferences() {
    // This factory constructor is used to return the static instance
    if (instance == null) {
      throw Exception(
        'AppPreferences not initialized. Call AppPreferences.init() first.',
      );
    }
    return instance!;
  }

  // Setting the shared preferences instance.
  Future<void> setsharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<bool> changeBooleanSharedPref(String name, bool value) async {
    var result = await sharedPreferences.setBool(name, value);

    /*
     * By using notifyListeners,we can alert all listening parties
     * that something has changed. If the listening party is a child widget
     * it may rebuild itself.
     */
    notifyListeners();
    // we need to alert the listeners for PetraUser as well.
    // PetraUser.instance.addListener(() { })
    return result;
  }

  bool fetchBooleanSharedPref(String name, {bool defaultValue = false}) {
    return sharedPreferences.getBool(name) ?? defaultValue;
  }

  Future<bool> changeStringSharedPref(String name, String value) async {
    var result = await sharedPreferences.setString(name, value);
    /*
     * By using notifyListeners,we can alert all listening parties
     * that something has changed. If the listening party is a child widget
     * it may rebuild itself.
     */
    notifyListeners();
    return result;
  }

  String? fetchStringSharedPref(String name) {
    return sharedPreferences.getString(name);
  }

  Future<bool> changeJSONPetraUser(PetraUser user) async {
    // Get a json representation of the user
    var userMap = user.getJSONString();
    var result = await sharedPreferences.setString('user', userMap);
    notifyListeners();
    return result;
  }

  String? fetchJSONPetraUser() {
    return sharedPreferences.getString('user');
  }

  bool isAPIEndpointSet() {
    var codeSet = instance!.fetchBooleanSharedPref(
      AppPreferenceKeys.isSchoolCodeSet,
    );
    return codeSet;
  }

  String getBackendDomain(String code) {
    // Special handling for 'test' code
    if ('test' == code) {
      return 'https://petra.test/public/index.php';
    }

    // Special handling for 'qa' code
    if ('qa' == code) {
      return 'https://demo.qa.petrasoft.co.in/public/index.php';
    }

    return 'https://$code.petrasoft.co.in/public/index.php';
  }
}
