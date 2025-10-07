import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/local_utils/auth.service.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/widgets/school_code_screen.dart';
import 'package:petrasoft_school_management_solutions/bl/dashboard/widgets/dashboard.widget.dart';
import 'package:petrasoft_school_management_solutions/flavors.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const String page = '/login'; // For consistency with other screens

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = AuthService();
        final result = await authService.signInWithUsernameAndPassword(
          _usernameController.text,
          _passwordController.text,
        );

        if (mounted) {
          if (result['status_code'] == 200) {
            // Login successful - navigate to dashboard
            Navigator.of(context).pushReplacementNamed(Dashboard.page);
          } else {
            // Login failed - show error message
            setState(() {
              _errorMessage =
                  result['message'] ??
                  AppLocalizations.of(context)?.loginFailedMessage ??
                  "Login failed. Please try again.";
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Login error: $e");
        }
        if (mounted) {
          setState(() {
            _errorMessage =
                AppLocalizations.of(context)?.loginFailedMessage ??
                "Login failed. Please try again.";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _switchSchool() async {
    // Reset school code settings
    final appPrefs = AppPreferences();
    await appPrefs.changeBooleanSharedPref(
      AppPreferenceKeys.isSchoolCodeSet,
      false,
    );
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(SchoolCodeScreen.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.loginTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Username field
              Text(
                localizations.usernameLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('username-field'),
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.usernameRequiredError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password field
              Text(
                localizations.passwordLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('password-field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.passwordRequiredError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Error message if login fails
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 24),

              // Login button
              Center(
                child: ElevatedButton(
                  key: const Key('loginButton'),
                  onPressed: _isLoading ? null : _handleLogin,
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
                          localizations.loginButton,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Register button
              Center(
                child: TextButton(
                  key: const Key('registerButton'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.registrationNotImplemented),
                      ),
                    );
                  },
                  child: Text(
                    localizations.registerButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Switch school link
              Center(
                child: TextButton(
                  key: const Key('switchSchoolButton'),
                  onPressed: _switchSchool,
                  child: Text(
                    localizations.switchSchoolButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Petrasoft Solutions logo at the bottom
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: SvgPicture.asset(
                        'assets/${F.appFlavor.name}/logo.svg',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.petrasoftSolutionsText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
