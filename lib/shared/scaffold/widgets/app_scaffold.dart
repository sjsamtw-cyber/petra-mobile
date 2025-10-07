import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/attendance_alert_message.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/attendance_alert_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/attendance_percentage_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/mark_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/review_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/login_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/school_code_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/settings_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/widgets/calendar_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/dashboard/widgets/dashboard.widget.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/about.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/get_help.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/privacy_policy.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/widgets/notices_screen.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/local_utils/firebase.service.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/models/notification_event.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  final Widget scaffoldBody;
  final bool showBackButton;

  const AppScaffold({
    super.key,
    required this.scaffoldBody,
    this.showBackButton = false,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final FirebaseService _firebaseService;
  StreamSubscription<NotificationEvent>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription = _firebaseService.notificationStream.listen(
      _handleNotificationEvent,
    );
  }

  void _handleNotificationEvent(NotificationEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case 'notice-alert':
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(NoticesScreen.page, (route) => false);
        break;
      case 'attendance-alert':
        if (event.data.containsKey('student_name')) {
          final attendanceAlertMsg = AttendanceAlertMessage(
            studentName: event.data['student_name'],
            markedBy: event.data['marked_by'],
            markedTime: event.data['marked_time'],
            markedForDate: event.data['marked_for_date'],
            imageURL: event.data['image_url'],
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            AttendanceAlertScreen.page,
            (route) => false,
            arguments: {'message': attendanceAlertMsg},
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            ReviewAttendanceScreen.page,
            (route) => false,
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  String _getPageTitle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Auto-detect page title based on widget type
    if (widget.scaffoldBody is SettingsScreen) {
      return localizations.settingsTitle;
    }
    if (widget.scaffoldBody is About) {
      return localizations.aboutUsText;
    }
    if (widget.scaffoldBody is PrivacyPolicy) {
      return localizations.privacyPolicyText;
    }
    if (widget.scaffoldBody is GetHelp) {
      return localizations.getHelpText;
    }
    if (widget.scaffoldBody is MarkAttendanceScreen) {
      return localizations.markAttendanceTitle;
    }
    if (widget.scaffoldBody is ReviewAttendanceScreen) {
      return localizations.reviewAttendanceTitle;
    }
    if (widget.scaffoldBody is AttendancePercentageScreen) {
      return localizations.attendancePercentageTitle;
    }
    if (widget.scaffoldBody is CalendarScreen) {
      return localizations.calendarTitle;
    }
    if (widget.scaffoldBody is NoticesScreen) {
      return localizations.notices;
    }
    if (widget.scaffoldBody is AttendanceAlertScreen) {
      return localizations.attendanceAlertTitle;
    }

    // Default title or empty
    return '';
  }

  bool _shouldShowBackButton() {
    if (widget.showBackButton) return true;

    // Auto-detect if back button should be shown
    return widget.scaffoldBody is SettingsScreen ||
        widget.scaffoldBody is About ||
        widget.scaffoldBody is PrivacyPolicy ||
        widget.scaffoldBody is GetHelp ||
        widget.scaffoldBody is MarkAttendanceScreen ||
        widget.scaffoldBody is ReviewAttendanceScreen ||
        widget.scaffoldBody is AttendancePercentageScreen ||
        widget.scaffoldBody is CalendarScreen ||
        widget.scaffoldBody is NoticesScreen;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on login or school code screen to hide the drawer
    final bool isLoginScreen = widget.scaffoldBody is LoginScreen;
    final bool isSchoolCodeScreen = widget.scaffoldBody is SchoolCodeScreen;
    final bool shouldHideDrawer = isLoginScreen || isSchoolCodeScreen;
    final String pageTitle = _getPageTitle(context);
    final bool showBackButton = _shouldShowBackButton();

    return ChangeNotifierProvider<PetraUser>.value(
      // Use the PetraUser singleton instance
      value: PetraUser.instance,
      child: Scaffold(
        key: const Key('appScaffoldScaffold'),
        appBar: shouldHideDrawer
            ? null
            : AppBar(
                key: const Key('appScaffoldAppBar'),
                leading: showBackButton
                    ? IconButton(
                        key: const Key('appScaffoldBackButton'),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
                title: pageTitle.isNotEmpty
                    ? Text(
                        pageTitle,
                        key: const Key('appScaffoldAppBarTitle'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      )
                    : null,
                actions: [
                  // Home icon - conditionally show if user is logged in
                  Consumer<PetraUser>(
                    builder: (context, user, child) {
                      if (user.userType != UserType.NOBODY) {
                        return IconButton(
                          key: const Key('appScaffoldHomeButton'),
                          icon: const Icon(Icons.home),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Dashboard.page,
                              (route) => false,
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  IconButton(
                    key: const Key('appScaffoldProfileButton'),
                    icon: SvgPicture.asset(
                      'assets/general/icons/profile.svg',
                      // colorFilter to respect system light/dark mode
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(SettingsScreen.page);
                    },
                  ),
                ],
              ),
        body: KeyedSubtree(
          key: const Key('appScaffoldBody'),
          child: widget.scaffoldBody,
        ),
      ),
    );
  }

  // AppScaffold implementation
}
