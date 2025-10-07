// create a singleton class for http requests
// this will have a dio instance  with the below base options
/*
 final options = BaseOptions(
    baseUrl: 'https://api.pub.dev', // Get the base url from the app preferences
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  );
  final anotherDio = Dio(options);
  */
// The dio base url shoudl change whenever the
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

class PetraHttp {
  late final Dio _dio;
  static final PetraHttp _instance = PetraHttp._internal();
  var appPreferences = AppPreferences();
  factory PetraHttp() => _instance;

  PetraHttp._internal() {
    var apiUrl = appPreferences.fetchStringSharedPref(AppPreferenceKeys.apiURL);
    // Check if apiUrl is null
    final options = BaseOptions(
      baseUrl: apiUrl ?? AppPreferenceConstants.devDomain,
      connectTimeout: const Duration(
        seconds: AppPreferenceConstants.httpConnectTimeoutSeconds,
      ),
      receiveTimeout: const Duration(
        seconds: AppPreferenceConstants.httpReceiveTimeoutSeconds,
      ),
    );
    _dio = Dio(options);
    appPreferences.addListener(() {
      var apiUrl = appPreferences.fetchStringSharedPref(
        AppPreferenceKeys.apiURL,
      );
      // Check if apiUrl is not null and not the same as the current base url
      if (apiUrl != null && apiUrl != _dio.options.baseUrl) {
        _dio.options.baseUrl = apiUrl;
      }
    });
  }

  Future<dynamic> get(String url) async {
    // make http get request
    return _dio.get(url);
  }

  Future<dynamic> post(
    String url,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) async {
    // make http post request with options for headers
    Options options = Options();
    if (headers != null) {
      options.headers = headers;
    }

    try {
      return await _dio.post(url, data: data, options: options);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
        throw TimeoutException('Connection timed out');
      }
      rethrow;
    }
  }

  Future<dynamic> put(String url, dynamic data) async {
    // make http put request
  }

  Future<dynamic> delete(String url) async {
    // make http delete request
  }
}
