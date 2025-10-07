import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/attendance_percentage_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/mark_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/widgets/review_attendance_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/login_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/widgets/calendar_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/info/widgets/about.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/widgets/notices_screen.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/version_check/version_checker.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  static const String page = '/dashboard';

  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool notificationPermissionGranted = false;
  final versionCheck = VersionChecker();
  late DateTime selectedDate;

  // Dashboard button configuration
  static const Map<String, DashboardButtonConfig> _dashboardButtons = {
    'mark_attendance': DashboardButtonConfig(
      icon: Icons.check_circle_outline,
      labelKey: 'markAttendanceText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN],
      route: MarkAttendanceScreen.page,
    ),
    'review_attendance': DashboardButtonConfig(
      icon: Icons.view_list,
      labelKey: 'reviewAttendanceText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
      route: ReviewAttendanceScreen.page,
    ),
    'attendance_percentage': DashboardButtonConfig(
      icon: Icons.bar_chart,
      labelKey: 'attendancePercentageText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
      route: AttendancePercentageScreen.page,
    ),
    'notice_board': DashboardButtonConfig(
      icon: Icons.notifications_outlined,
      labelKey: 'noticeBoardText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
      route: NoticesScreen.page,
    ),
    // 'bus_tracking': DashboardButtonConfig(
    //   icon: Icons.directions_bus,
    //   labelKey: 'busTrackingText',
    //   allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
    //   action: DashboardButtonAction.debug,
    // ),
    'calendar': DashboardButtonConfig(
      icon: Icons.calendar_month,
      labelKey: 'calendarText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
      route: CalendarScreen.page, // Assuming SchoolCalendar is the correct page
    ),
    'about_us': DashboardButtonConfig(
      icon: Icons.info_outline,
      labelKey: 'aboutUsText',
      allowedRoles: [UserType.TEACHER, UserType.ADMIN, UserType.PARENT],
      route: About.page,
    ),
  };

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    // Check if user is logged in and redirect if not
    checkUserLoggedIn();

    // Initialize requirements check in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Continue with other requirements checks
      checkRequirements(AppLocalizations.of(context));
    });
  }

  void checkUserLoggedIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now we can safely use context after the widget is built
      // Get PetraUser instance from provider
      final user = Provider.of<PetraUser>(context, listen: false);

      // If user is not logged in (null or not authenticated), redirect to login page
      if (user.apiToken.isEmpty) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.page);
      }
    });
  }

  Future<void> checkRequirements(AppLocalizations? localizations) async {
    await requestNotificationPermission(localizations);
    await checkVersion(localizations);
  }

  Future<void> requestNotificationPermission(
    AppLocalizations? localizations,
  ) async {
    var status = await Permission.notification.status;
    // Check ios then set true else (status == PermissionStatus.granted)
    notificationPermissionGranted =
        Platform.isIOS || status == PermissionStatus.granted;

    final appPrefs = AppPreferences();
    final hasShownNotificationDialog =
        appPrefs.fetchBooleanSharedPref(
          AppPreferenceKeys.notificationDialogShown,
        ) ==
        true;

    if (!notificationPermissionGranted &&
        !hasShownNotificationDialog &&
        mounted &&
        localizations != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.enableNotifications),
            content: Text(localizations.notificationPermissionMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: Text(localizations.openSettings),
              ),
            ],
          );
        },
      );

      await appPrefs.changeBooleanSharedPref(
        AppPreferenceKeys.notificationDialogShown,
        true,
      );
    }
  }

  Future<void> checkVersion(AppLocalizations? localizations) async {
    final appPrefs = AppPreferences();
    final hasShownUpdateDialog =
        appPrefs.fetchBooleanSharedPref(AppPreferenceKeys.updateDialogShown) ==
        true;

    if (!hasShownUpdateDialog &&
        notificationPermissionGranted &&
        mounted &&
        localizations != null) {
      await versionCheck.checkVersion(context);

      if (versionCheck.packageVersion != versionCheck.storeVersion &&
          versionCheck.storeVersion != null &&
          mounted) {
        // Check mounted again before using context
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.updateAvailable),
              content: Text(localizations.updateMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await versionCheck.launchStore();
                  },
                  child: Text(localizations.update),
                ),
              ],
            );
          },
        );
      }

      await appPrefs.changeBooleanSharedPref(
        AppPreferenceKeys.updateDialogShown,
        true,
      );
    }
  }

  List<DashboardButtonConfig> _getAvailableButtons(UserType userType) {
    return _dashboardButtons.values
        .where((config) => config.allowedRoles.contains(userType))
        .toList();
  }

  String _getLocalizedLabel(AppLocalizations localizations, String labelKey) {
    switch (labelKey) {
      case 'markAttendanceText':
        return localizations.markAttendanceText;
      case 'reviewAttendanceText':
        return localizations.reviewAttendanceText;
      case 'attendancePercentageText':
        return localizations.attendancePercentageText;
      case 'noticeBoardText':
        return localizations.noticeBoardText;
      case 'busTrackingText':
        return localizations.busTrackingText;
      case 'calendarText':
        return localizations.calendarText;
      case 'aboutUsText':
        return localizations.aboutUsText;
      default:
        return labelKey;
    }
  }

  void _handleButtonTap(DashboardButtonConfig config) {
    switch (config.action) {
      case DashboardButtonAction.route:
        if (config.route != null) {
          Navigator.pushNamed(context, config.route!);
        }
        break;
      case DashboardButtonAction.debug:
        if (kDebugMode) {
          print('${config.labelKey} tapped');
        }
        break;
      case DashboardButtonAction.custom:
        if (config.customAction != null) {
          config.customAction!();
        }
        break;
    }
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    // Use label as part of the key for uniqueness
    return GestureDetector(
      key: Key('dashboardButton_$label'),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 2),
            child: Icon(icon, size: 40, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            key: Key('dashboardButtonLabel_$label'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final user = Provider.of<PetraUser>(context, listen: false);
    final availableButtons = _getAvailableButtons(user.userType);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.dashboardWelcome(user.firstName),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.secondary,
            ),
          ),

          const SizedBox(height: 24),

          // Calendar Widget
          PetraCalendar(
            selectedDate: selectedDate,
            selectionMode: CalendarSelectionMode.none,
            showNavigation: true,
            showSelectedDateIndicator: false,
          ),

          const SizedBox(height: 32),

          // Dashboard Buttons Grid - Role-based filtering
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: availableButtons.map((config) {
              final label = _getLocalizedLabel(localizations, config.labelKey);
              return _buildDashboardButton(
                icon: config.icon,
                label: label,
                onTap: () => _handleButtonTap(config),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Dashboard button configuration classes
enum DashboardButtonAction { route, debug, custom }

class DashboardButtonConfig {
  final IconData icon;
  final String labelKey;
  final List<UserType> allowedRoles;
  final String? route;
  final DashboardButtonAction action;
  final VoidCallback? customAction;

  const DashboardButtonConfig({
    required this.icon,
    required this.labelKey,
    required this.allowedRoles,
    this.route,
    this.action = DashboardButtonAction.route,
    this.customAction,
  });
}
