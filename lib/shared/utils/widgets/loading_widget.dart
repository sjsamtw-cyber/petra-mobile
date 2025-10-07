import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';

/// A loading widget that uses the app theme colors and shows a centered CircularProgressIndicator.
/// This widget is used during loading states in the app.
class LoadingWidget extends StatelessWidget {
  /// Creates a loading widget.
  ///
  /// The [key] is forwarded to the superclass.
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);

    return Container(
      key: const Key('loadingWidgetContainer'),
      color: colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SpinKit for consistent loading animations (same as Welcome screen)
            SpinKitFadingFour(
              key: const Key('loadingWidgetSpinner'),
              color: colorScheme
                  .primary, // Using theme color instead of hardcoded black
              size: 50.0,
            ),
            const SizedBox(height: 24),
            // Loading text with proper theme styling
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  localizations?.loadingText ?? 'Loading...',
                  key: const Key('loadingWidgetText'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
