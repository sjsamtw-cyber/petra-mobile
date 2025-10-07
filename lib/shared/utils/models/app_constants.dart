// A central place for app-wide constants
import 'package:flutter/material.dart';

/// Application constants that can be used across the app
class AppConstants {
  // Timing constants
  static const Duration splashScreenDuration = Duration(seconds: 3);

  // Shared preference keys
  static const String firstLaunchCompletedKey = 'first_launch_completed';
  static const String userPresentKey = 'user_present';
  static const String apiTokenKey = 'api_token';

  // UI constants
  static const double drawerFontSize = 20.0;
  static const double drawerTopPadding = 50.0;
  static const double defaultSpacing = 8.0;
  static const double defaultPadding = 16.0;
  static const double largeSpacing = 24.0;

  // Colors (prefer using theme.colorScheme over these when possible)
  static const Color drawerBackgroundColor = Colors.black87;
  static const Color drawerTextColor = Colors.white;

  // Animation constants
  static const double loadingIndicatorSize = 50.0;

  // Network constants
  static const int defaultTimeoutInSeconds = 30;
  static const String connectionTimeoutError = 'Connection Timed Out';
}
