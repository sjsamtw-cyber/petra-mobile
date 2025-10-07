import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/user_constants.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_gender.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

class PetraUser extends ChangeNotifier {
  late String firstName;
  late String lastName;
  late String userName;
  late String email;
  late String phoneNumber;
  late String apiToken;
  late UserType userType;
  late String? imageUrl;
  late UserGender? gender;

  static late PetraUser instance;

  static Future<void> init() async {
    instance = PetraUser._init();
    instance.updateFromSharedPrefs();
  }

  PetraUser._init() {
    firstName = lastName = userName = email = phoneNumber = apiToken = '';
    userType = UserType.NOBODY;
    imageUrl = null;
    gender = null;
  }

  void resetToNobody() {
    firstName = lastName = userName = email = phoneNumber = apiToken = '';
    userType = UserType.NOBODY;
    imageUrl = null;
    gender = null;
    notifyListeners();
  }

  void setToSomebody({
    required String nameFirst,
    required String nameLast,
    required String usrName,
    required String userEmail,
    required String phoneNum,
    required String token,
    required int typeNumber,
    String? userImageUrl,
    UserGender? userGender,
  }) {
    firstName = nameFirst;
    lastName = nameLast;
    userName = usrName;
    email = userEmail;
    phoneNumber = phoneNum;
    apiToken = token;
    userType = getUserType(typeNumber);
    imageUrl = userImageUrl;
    gender = userGender;
    notifyListeners();
  }

  UserType getUserType(int typeNumber) {
    switch (typeNumber) {
      case -1:
        return UserType.NOBODY;
      case 0:
        return UserType.ADMIN;
      case 1:
        return UserType.STUDENT;
      case 2:
        return UserType.PARENT;
      case 3:
        return UserType.TEACHER;
      case 4:
        return UserType.GUARDIAN;
      case 5:
        return UserType.NONTEACHINGSTAFF;
      default:
        return UserType.NOBODY;
    }
  }

  /*
   * getPetraUserFromSharedPref
   * The below static function serves as the data point
   * for Provider<PetraUser>.value 
   * Plan of action 
   *   1 Check if the shared preference 'api_token' exist.
   *   2 If 'api_token' exist - 
   *     Query the sqlite database to get the user details.
   *   3 Call the PetraUser factory function
   */
  void updateFromSharedPrefs() async {
    var appPrefsInstance = AppPreferences();
    var userPresent = appPrefsInstance.fetchBooleanSharedPref(
      AppPreferenceKeys.userPresent,
    );
    var user = appPrefsInstance.fetchJSONPetraUser();
    if (!userPresent || user == null) {
      // PetraUser type will be UserType.NOBODY here
      resetToNobody();
    } else {
      /*
       * Fetch the user details from the shared preferences
       * user data is present
       */
      var userDataMap = jsonDecode(user);
      setToSomebody(
        nameFirst: userDataMap[UserPreferenceKeys.firstNameKey].toString(),
        nameLast: userDataMap[UserPreferenceKeys.lastNameKey].toString(),
        usrName: userDataMap[UserPreferenceKeys.userNameKey].toString(),
        userEmail: userDataMap[UserPreferenceKeys.emailKey].toString(),
        phoneNum: userDataMap[UserPreferenceKeys.phoneNumberKey].toString(),
        token: userDataMap[UserPreferenceKeys.apiTokenKey].toString(),
        typeNumber: int.parse('${userDataMap[UserPreferenceKeys.userTypeKey]}'),
        userImageUrl: userDataMap[UserPreferenceKeys.imageUrlKey],
        userGender: userDataMap[UserPreferenceKeys.genderKey] != null
            ? UserGenderDetails.getGenderFromNumber(
                userDataMap[UserPreferenceKeys.genderKey],
              )
            : null,
      );
    }
  }

  String getJSONString() {
    // Take the user of object and convert it to a JSON string using built-in dart functions
    return jsonEncode({
      UserPreferenceKeys.apiTokenKey: apiToken,
      UserPreferenceKeys.firstNameKey: firstName,
      UserPreferenceKeys.lastNameKey: lastName,
      UserPreferenceKeys.userNameKey: userName,
      UserPreferenceKeys.emailKey: email,
      UserPreferenceKeys.phoneNumberKey: phoneNumber,
      UserPreferenceKeys.userTypeKey: userType.index,
      UserPreferenceKeys.imageUrlKey: imageUrl,
      UserPreferenceKeys.genderKey: gender?.index,
    });
  }
}
