import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petrasoft_school_management_solutions/flavors.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/local_utils/firebase.service.dart';
import 'package:url_launcher/url_launcher.dart'; // Added import

import 'login_screen.dart'; // Added import for LoginScreen

class SchoolCodeScreen extends StatefulWidget {
  static const String page = '/school_code'; // Define a route name

  const SchoolCodeScreen({super.key});

  @override
  State<SchoolCodeScreen> createState() => _SchoolCodeScreenState();
}

class _SchoolCodeScreenState extends State<SchoolCodeScreen> {
  final _schoolCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitSchoolCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final schoolCode = _schoolCodeController.text.trim();
      bool isValid = false;

      try {
        // Firestore check based on petra_mobile logic
        final firestore = FirebaseService().firebaseFirestore;
        final docSnapshot = await firestore
            .collection('school_codes')
            .doc('codes')
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data.containsKey('codes')) {
            final List<dynamic> validSchoolCodes = data['codes'] ?? [];
            if (validSchoolCodes.contains(schoolCode)) {
              isValid = true;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error validating school code: $e");
        }
        if (mounted) {
          setState(() {
            _errorMessage =
                AppLocalizations.of(context)?.errorValidatingCode ??
                "Error validating code. Please try again.";
          });
        }
      }

      if (mounted) {
        // Check if widget is still in the tree
        if (isValid) {
          // This block of code might seem redundant/duplicate,
          // but it done this way to ensure that a developer can
          // easily understand the flow of the code.
          // Save school code using AppPreferences
          final appPreferences = AppPreferences();
          await appPreferences.changeStringSharedPref(
            AppPreferenceKeys.schoolCode,
            schoolCode,
          );
          // Also set the isSchoolCodeSet flag to true
          await appPreferences.changeBooleanSharedPref(
            AppPreferenceKeys.isSchoolCodeSet,
            true,
          );
          // Set the API URL based on the school code
          final apiUrl = appPreferences.getBackendDomain(schoolCode);
          await appPreferences.changeStringSharedPref(
            AppPreferenceKeys.apiURL,
            apiUrl,
          );

          if (kDebugMode) {
            print("School code is valid and saved: $schoolCode");
            print("API URL set to: $apiUrl");
          }
          // Navigate to the next screen (e.g., Login or Dashboard)
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(LoginScreen.page);
          }
        } else {
          setState(() {
            _errorMessage =
                AppLocalizations.of(context)?.invalidSchoolCode ??
                "Invalid school code.";
          });
        }

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _joinUsToday() async {
    // Implement navigation or action for "Join us today"
    // This could open a web page or a different part of the app.
    final Uri url = Uri.parse('https://petrasoftsolutions.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle the error or show a message to the user
      if (kDebugMode) {
        print("Could not launch $url");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotOpenLink ??
                  "Could not open the link.",
            ),
          ),
        );
      }
    }
    if (kDebugMode) {
      print("Join us today tapped");
    }
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Using textTheme from the material theme for consistency
    final labelMedium = theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    final labelMediumOnPrimary = theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.onPrimary,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    final bodyMedium = theme.textTheme.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );
    final captionItalic = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      fontSize: 12,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.enterSchoolCodeTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                key: const Key('schoolCodeInput'),
                controller: _schoolCodeController,
                decoration: InputDecoration(
                  labelText: localizations.schoolCodeLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: HSVColor.fromColor(
                        colorScheme.onSurfaceVariant,
                      ).withValue(0.5).toColor(), // Softer border
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: HSVColor.fromColor(
                        colorScheme.onSurfaceVariant,
                      ).withValue(0.3).toColor(),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.schoolCodeRequiredError;
                  }
                  return null;
                },
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  key: const Key('submitSchoolCodeButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: _isLoading ? null : _submitSchoolCode,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          localizations.submitButton,
                          style: labelMediumOnPrimary?.copyWith(
                            letterSpacing: 0.1,
                          ),
                        ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 64.0),
              Text(
                localizations.notAPartOfFamilyText,
                textAlign: TextAlign.center,
                style: bodyMedium,
              ),
              const SizedBox(height: 8.0),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                key: const Key('joinUsButton'),
                onPressed: _isLoading ? null : _joinUsToday,
                child: Text(
                  localizations.joinUsTodayButton,
                  style: labelMedium?.copyWith(letterSpacing: 0.1),
                ),
              ),
              const SizedBox(height: 100),
              Column(
                children: [
                  SizedBox(
                    key: const Key('petrasoftLogo'),
                    width: 42,
                    height: 42,
                    child: SvgPicture.asset(
                      'assets/${F.appFlavor.name}/logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    localizations.petrasoftSolutionsText,
                    style: captionItalic,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
