import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/debug/petra_http_overrides.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/local_utils/firebase.service.dart';
import 'package:petrasoft_school_management_solutions/services/router/models/petra_router.dart';
import 'package:petrasoft_school_management_solutions/shared/theme/models/theme.model.dart';
import 'package:petrasoft_school_management_solutions/shared/welcome_screen/widgets/welcome_screen.widget.dart';

import 'flavors.dart';

void main() async {
  var flavor = const String.fromEnvironment(
    'PETRA_APP_FLAVOR',
    defaultValue: 'dev',
  );
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.values.firstWhere((element) => element.name == flavor);

  // Initialize HTTP overrides for self-signed certificates in debug mode
  if (kDebugMode) {
    HttpOverrides.global = PetraHttpOverrides();
  }

  await AppPreferences.init();
  await FirebaseService.init();
  PetraUser.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MaterialTheme myTheme = const MaterialTheme(Typography.englishLike2021);
  late AppPreferences _appPreferences;
  bool _isDarkMode = false;
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _appPreferences = AppPreferences();
    _isDarkMode = _appPreferences.fetchBooleanSharedPref(
      AppPreferenceKeys.isDarkModeEnabled,
    );
    _currentLocale =
        _appPreferences.fetchStringSharedPref(AppPreferenceKeys.appLocale) ??
        'en';
    // Listen to preference changes
    _appPreferences.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _appPreferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    final newIsDarkMode = _appPreferences.fetchBooleanSharedPref(
      AppPreferenceKeys.isDarkModeEnabled,
    );
    final newLocale =
        _appPreferences.fetchStringSharedPref(AppPreferenceKeys.appLocale) ??
        'en';

    if (_isDarkMode != newIsDarkMode || _currentLocale != newLocale) {
      setState(() {
        _isDarkMode = newIsDarkMode;
        _currentLocale = newLocale;
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: F.title,
      theme: _isDarkMode ? myTheme.dark() : myTheme.light(),
      locale: Locale(_currentLocale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: WelcomeScreen.page,
      onGenerateRoute: (settings) {
        return PetraRouter.onGenerateRoute(context, settings);
      },
    );
  }
}
