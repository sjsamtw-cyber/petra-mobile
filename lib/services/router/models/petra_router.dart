// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/router/widgets/widget_picker.dart';
import 'package:petrasoft_school_management_solutions/shared/scaffold/widgets/app_scaffold.dart';
import 'package:petrasoft_school_management_solutions/shared/welcome_screen/widgets/welcome_screen.widget.dart';

class PetraRouter {
  /*
   * function : onGenerateRoute
   * To be passed to the 'onGenerateRoute' option of the MaterialApp
   * The above option takes an argument of type:
   *   Route<dynamic> Function(RouteSettings) onGenerateRoute}
   */

  static Route<dynamic> onGenerateRoute(
    BuildContext context,
    RouteSettings settings,
  ) {
    /*
       * We are dealing with named routes here.
       * What we are particularly interested here are two properties
       *   - settings.name
       *   - settings.arguments
       */
    String routeName = settings.name!;
    Object? routeArguements = settings.arguments;
    return MaterialPageRoute(
      builder: (context) {
        /*
       * Note that we're getting the build context as an argument
       * but we are not using it. In a big application, it is suggested
       * that we do not discard the context, as it might have some
       * use case later.
       */
        Widget scaffoldBody = getWidget(routeName, routeArguements);

        String? appLocale = AppPreferences().fetchStringSharedPref(
          AppPreferenceKeys.appLocale,
        );
        String? countryCode = AppPreferences().fetchStringSharedPref(
          AppPreferenceKeys.countryCode,
        );

        // Provide default values if not set
        appLocale = appLocale?.isNotEmpty == true ? appLocale : 'en';
        countryCode = countryCode?.isNotEmpty == true ? countryCode : 'US';

        return Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: Locale(appLocale!, countryCode!),
          child: routeName == WelcomeScreen.page
              ? scaffoldBody
              : AppScaffold(scaffoldBody: scaffoldBody),
        );
      },
    );
  }
}
