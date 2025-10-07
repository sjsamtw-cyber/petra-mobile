/*
 * Set up an authentication service based on shared preferences.
 * From Package Documentation
 * Wraps platform-specific persistent storage for simple data
 * (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.).
 * Data may be persisted to disk asynchronously,
 * and there is no guarantee that writes will be persisted
 * to disk after returning,
 * so this plugin must not be used for storing critical data.
 */

// Dart SDK
import 'dart:async';

// Flutter Framework
import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/user_constants.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/local_utils/petra_http.service.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoint_manager.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoints.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/local_utils/firebase.service.dart';

// Flutter Plugins

class AuthService {
  static final AuthService authServiceSingleton = AuthService._internal();

  factory AuthService() {
    return authServiceSingleton;
  }

  AuthService._internal();

  Future<Map<String, dynamic>> signInWithUsernameAndPassword(
    String userName,
    String password,
  ) async {
    try {
      var url = EndPointManager.getEndpoint(Endpoint.login);
      var fcmToken = await FirebaseService().fcmDeviceToken;

      var response = await PetraHttp().post(
        url,
        {'user_nm': userName, 'password': password},
        headers: {'x-fcm-token': fcmToken},
      );

      if (!kReleaseMode) {
        debugPrint(response.toString());
      }

      if (response.statusCode != 200) {
        return {
          'status_code': response.statusCode,
          'message': response.statusMessage,
        };
      } else {
        var responseBody = response.data;

        if (responseBody['status_code'] == 200) {
          PetraUser.instance.setToSomebody(
            token: responseBody['api_token'],
            nameFirst: responseBody['user']['first_name'] ?? '',
            nameLast: responseBody['user']['last_name'] ?? '',
            usrName: responseBody['user']['user_nm'] ?? '',
            userEmail: responseBody['user']['email'] ?? '',
            phoneNum: responseBody['user']['phone_number'].toString(),
            typeNumber: responseBody['user']['user_type'] ?? '',
          );

          var appPrefs = AppPreferences();
          await appPrefs.changeBooleanSharedPref(
            AppPreferenceKeys.userPresent,
            true,
          );
          await appPrefs.changeStringSharedPref(
            UserPreferenceKeys.apiTokenKey,
            responseBody['api_token'],
          );

          await appPrefs.changeJSONPetraUser(PetraUser.instance);
        }

        return {
          'status_code': responseBody['status_code'],
          'message': responseBody['message'],
        };
      }
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  Future<bool> signOut() async {
    var appPrefs = AppPreferences();
    var apiToken = appPrefs.fetchStringSharedPref(
      UserPreferenceKeys.apiTokenKey,
    );

    // Only attempt to call the API if we have a token
    if (apiToken != null && apiToken.isNotEmpty) {
      var fcmToken = await FirebaseService().fcmDeviceToken;
      var url = EndPointManager.getEndpoint(Endpoint.logout);

      try {
        var response = await PetraHttp().post(
          url,
          {},
          headers: {
            'authorization': 'Bearer $apiToken',
            'x-api-token': apiToken,
            'x-fcm-token': fcmToken,
          },
        );

        if (!kReleaseMode) {
          var jsonResponse = response.data;
          if (jsonResponse['status_code'] != 200) {
            debugPrint('User token may not be reset upstream');
          }
        }
      } catch (e) {
        debugPrint('Error during logout: ${e.toString()}');
        // Continue with local logout even if server logout fails
      }
    }

    // Always clear local authentication state regardless of API call result
    var result1 = await appPrefs.changeBooleanSharedPref(
      AppPreferenceKeys.userPresent,
      false,
    );
    var result2 = await appPrefs.changeStringSharedPref(
      UserPreferenceKeys.apiTokenKey,
      '',
    );
    PetraUser.instance.updateFromSharedPrefs();

    return result1 && result2;
  }
}
