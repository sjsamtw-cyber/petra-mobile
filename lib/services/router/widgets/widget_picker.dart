// We do the widget selection heavy lifting here.
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/attendance_alert_message.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/attendance_alert_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/attendance_percentage_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/mark_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/review_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/login_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/school_code_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/settings_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/widgets/calendar_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/dashboard/widgets/dashboard.widget.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/about.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/get_help.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/privacy_policy.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/widgets/notices_screen.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/error.dart';
import 'package:petrasoft_school_management_solutions/shared/welcome_screen/widgets/welcome_screen.widget.dart';

Widget getWidget(String routeName, Object? routeArguments) {
  switch (routeName) {
    case WelcomeScreen.page:
      return const WelcomeScreen();
    case Dashboard.page:
      return const Dashboard();
    case About.page:
      return About();
    case PrivacyPolicy.page:
      return const PrivacyPolicy();
    case GetHelp.page:
      return const GetHelp();
    case SchoolCodeScreen.page:
      return const SchoolCodeScreen();
    case LoginScreen.page:
      return const LoginScreen();
    case SettingsScreen.page:
      return const SettingsScreen();
    case MarkAttendanceScreen.page:
      return const MarkAttendanceScreen();
    case ReviewAttendanceScreen.page:
      return const ReviewAttendanceScreen();
    case AttendancePercentageScreen.page:
      return const AttendancePercentageScreen();
    case CalendarScreen.page:
      return const CalendarScreen();
    case NoticesScreen.page:
      return const NoticesScreen();
    case AttendanceAlertScreen.page:
      // routeArguments is expected to be a Map<String, dynamic> with key 'message'
      AttendanceAlertMessage? alert;
      if (routeArguments is Map<String, dynamic> &&
          routeArguments['message'] is AttendanceAlertMessage) {
        alert = routeArguments['message'] as AttendanceAlertMessage;
      }
      return alert != null
          ? AttendanceAlertScreen(alert: alert)
          : const ReviewAttendanceScreen();
    default:
      return const ErrorPage();
  }
}
