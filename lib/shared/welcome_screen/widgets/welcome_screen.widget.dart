import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/school_code_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/dashboard/widgets/dashboard.widget.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/models/app_constants.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/branding.dart';

class WelcomeScreen extends StatefulWidget {
  static const String page = '/';
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _navigationTimer;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _ensurePreferencesInitialized();
  }

  // Make sure both AppPreferences and PetraUser are initialized
  Future<void> _ensurePreferencesInitialized() async {
    try {
      if (kDebugMode) {
        print("Initializing preferences and user...");
      }

      // Try to access AppPreferences and PetraUser instances
      try {
        AppPreferences();
        PetraUser.instance;
      } catch (e) {
        // Initialize if not already done
        if (kDebugMode) {
          print("Need to initialize: $e");
        }
        // These initializations should have been done in the main.
        // Raise the error again
        throw Exception(
          "AppPreferences or PetraUser not initialized properly.",
        );
      }

      // Start a timer to enforce minimum splash screen duration
      _navigationTimer = Timer(AppConstants.splashScreenDuration, () {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
          _navigateToNextScreen();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error during initialization: $e");
      }
      // Even if there's an error, navigate after splash screen duration
      _navigationTimer = Timer(AppConstants.splashScreenDuration, () {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
          // If initialization fails, go to school code screen as a fallback
          Navigator.of(context).pushReplacementNamed(SchoolCodeScreen.page);
        }
      });
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final appPreferences = AppPreferences();

    // Check if school code is set
    final schoolCode = appPreferences.sharedPreferences.getString(
      AppPreferenceKeys.schoolCode,
    );
    final isSchoolCodeSet = schoolCode?.isNotEmpty ?? false;

    if (isSchoolCodeSet) {
      // If school code is set, configure API endpoint
      final apiEndpoint = appPreferences.getBackendDomain(schoolCode!);
      appPreferences.changeStringSharedPref(
        AppPreferenceKeys.apiURL,
        apiEndpoint,
      );
      appPreferences.changeBooleanSharedPref(
        AppPreferenceKeys.isSchoolCodeSet,
        true,
      );

      // Navigate to Dashboard if school code is set
      Navigator.of(context).pushReplacementNamed(Dashboard.page);
    } else {
      // Navigate to SchoolCodeScreen if school code is not set
      Navigator.of(context).pushReplacementNamed(SchoolCodeScreen.page);
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('welcomeScreenContainer'),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PetrasoftBranding(
              key: const Key('welcomeScreenBranding'),
              logoSize: 125.0,
              spacing: 10.0,
              companyNameStyle: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  AppLocalizations.of(context)!.welcomeMessage,
                  key: const Key('welcomeScreenWelcomeText'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 50),
            SpinKitFadingFour(
              key: const Key('welcomeScreenSpinner'),
              color: colorScheme.primary,
              size: 50.0,
            ),
            if (_isInitializing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  AppLocalizations.of(context)?.loadingText ?? 'Loading...',
                  key: const Key('welcomeScreenLoadingText'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
