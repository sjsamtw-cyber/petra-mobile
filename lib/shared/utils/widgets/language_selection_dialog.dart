import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

class LanguageSelectionDialog extends StatefulWidget {
  final String currentLocale;

  const LanguageSelectionDialog({super.key, required this.currentLocale});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  final _appPrefs = AppPreferences();
  late String _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

  Future<String> _getLanguageDisplayName(String localeCode) async {
    try {
      // Create a temporary locale to get the human readable name
      final tempLocale = Locale(localeCode);
      final tempLocalizations = lookupAppLocalizations(tempLocale);
      return tempLocalizations.languageHumanReadableName;
    } catch (e) {
      // Fallback to uppercase locale code if there's an error
      return localeCode.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      key: const Key('languageDialog'),
      title: Text(
        localizations?.languageText ?? 'Language',
        key: const Key('languageDialogTitle'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          key: const Key('languageDialogListView'),
          shrinkWrap: true,
          itemCount: AppLocalizations.supportedLocales.length,
          itemBuilder: (context, index) {
            final locale = AppLocalizations.supportedLocales[index];
            final localeCode = locale.languageCode;

            return FutureBuilder<String>(
              future: _getLanguageDisplayName(localeCode),
              builder: (context, snapshot) {
                final displayName = snapshot.data ?? localeCode.toUpperCase();

                return RadioListTile<String>(
                  key: Key('languageRadio_$localeCode'),
                  title: Text(displayName),
                  subtitle: Text(localeCode.toUpperCase()),
                  value: localeCode,
                  groupValue: _selectedLocale,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLocale = value;
                      });
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          key: const Key('languageDialogCancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('languageDialogSubmit'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _appPrefs.changeStringSharedPref(
              AppPreferenceKeys.appLocale,
              _selectedLocale,
            );
            if (mounted) {
              navigator.pop(_selectedLocale);
            }
          },
          child: Text(localizations?.submitButton ?? 'Submit'),
        ),
      ],
    );
  }
}
