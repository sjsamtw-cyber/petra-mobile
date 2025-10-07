import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/auth.service.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/school_code_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/dashboard/widgets/dashboard.widget.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/language_selection_dialog.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const String page = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appPrefs = AppPreferences();

  Future<String> _getLanguageDisplayName(String localeCode) async {
    try {
      final tempLocale = Locale(localeCode);
      final tempLocalizations = lookupAppLocalizations(tempLocale);
      return tempLocalizations.languageHumanReadableName;
    } catch (e) {
      return localeCode.toUpperCase();
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.couldNotOpenAppSettings)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = _appPrefs.fetchBooleanSharedPref(
      AppPreferenceKeys.isDarkModeEnabled,
    );
    final localizations = AppLocalizations.of(context)!;
    final user = Provider.of<PetraUser>(context); // Get current user
    final currentLocale =
        _appPrefs.fetchStringSharedPref(AppPreferenceKeys.appLocale) ?? 'en';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile section
              Row(
                children: [
                  ProfileAvatar(
                    imageUrl: user.imageUrl,
                    gender: user.gender,
                    fallbackText: user.userName,
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Theme mode section
              Text(
                localizations.themeText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ThemeModeButton(
                    isSelected: !isDarkMode,
                    onTap: () async {
                      await _appPrefs.changeBooleanSharedPref(
                        AppPreferenceKeys.isDarkModeEnabled,
                        false,
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: Icons.light_mode_outlined,
                    label: localizations.lightModeText,
                    isDark: false,
                  ),
                  const SizedBox(width: 16),
                  _ThemeModeButton(
                    isSelected: isDarkMode,
                    onTap: () async {
                      await _appPrefs.changeBooleanSharedPref(
                        AppPreferenceKeys.isDarkModeEnabled,
                        true,
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: Icons.dark_mode_outlined,
                    label: localizations.darkModeText,
                    isDark: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Menu items section
              Text(
                localizations.preferencesText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                key: const Key('notificationsSettingItem'),
                icon: Icons.notifications_outlined,
                title: localizations.notificationsText,
                onTap: _openAppSettings,
              ),
              _MenuItem(
                key: const Key('languageSettingItem'),
                icon: Icons.language_outlined,
                title: localizations.languageText,
                trailing: FutureBuilder<String>(
                  future: _getLanguageDisplayName(currentLocale),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? currentLocale.toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
                onTap: () async {
                  if (!mounted) return;
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        LanguageSelectionDialog(currentLocale: currentLocale),
                  );
                  if (result != null && mounted) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 24),

              // Info section
              Text(
                localizations.informationText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                key: const Key('aboutUsSettingItem'),
                icon: Icons.info_outline,
                title: localizations.aboutUsText,
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
              ),
              _MenuItem(
                key: const Key('privacyPolicySettingItem'),
                icon: Icons.privacy_tip_outlined,
                title: localizations.privacyPolicyText,
                onTap: () {
                  Navigator.of(context).pushNamed('/privacy-policy');
                },
              ),
              _MenuItem(
                key: const Key('helpSettingItem'),
                icon: Icons.help_outline,
                title: localizations.getHelpText,
                onTap: () {
                  Navigator.of(context).pushNamed('/get-help');
                },
              ),
              const SizedBox(height: 24),

              // Account section
              Text(
                localizations.accountText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                key: const Key('switchSchoolSettingItem'),
                icon: Icons.swap_horiz_outlined,
                title: localizations.switchSchoolText,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await _appPrefs.changeBooleanSharedPref(
                    AppPreferenceKeys.isSchoolCodeSet,
                    false,
                  );
                  if (mounted) {
                    navigator.pushReplacementNamed(SchoolCodeScreen.page);
                  }
                },
              ),
              _MenuItem(
                key: const Key('signOutSettingItem'),
                icon: Icons.power_settings_new_outlined,
                title: localizations.signOutText,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final authService = AuthService();
                  await authService.signOut();
                  if (mounted) {
                    navigator.pushReplacementNamed(Dashboard.page);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isDark;

  const _ThemeModeButton({
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.onSurface),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24, color: theme.colorScheme.onSurface),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
