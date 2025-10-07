import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/branding.dart';

class GetHelp extends StatefulWidget {
  static const String page = '/get-help';

  const GetHelp({super.key});

  @override
  State<GetHelp> createState() => _GetHelpState();
}

class _GetHelpState extends State<GetHelp> {
  late FirebaseAnalytics analytics;
  late TextStyle addressTextStyle,
      contactTextStyle,
      companyNameStyle,
      labelTextStyle;
  late bool firstTime;

  @override
  void initState() {
    super.initState();
    analytics = FirebaseAnalytics.instance;
    firstTime = true;
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String content,
  }) {
    // Assign keys based on label for address/email, otherwise no key
    Key? contentKey;
    if (label.toLowerCase().contains('address')) {
      contentKey = const Key('getHelpAddress');
    } else if (label.toLowerCase().contains('email')) {
      contentKey = const Key('getHelpEmail');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: labelTextStyle),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(
            left: 28,
          ), // Align with text after icon
          child: Text(content, key: contentKey, style: contactTextStyle),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (firstTime) {
      // Setting the styles once and for all.
      labelTextStyle =
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ) ??
          const TextStyle();

      addressTextStyle =
          theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5) ??
          const TextStyle();

      contactTextStyle =
          theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.8,
            fontWeight: FontWeight.w500,
          ) ??
          const TextStyle();

      companyNameStyle =
          theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ) ??
          const TextStyle();

      firstTime = false;
    }

    return SingleChildScrollView(
      key: const Key('getHelpScrollView'),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Address section
          _buildContactItem(
            icon: Icons.location_on_outlined,
            label: l10n.address,
            content:
                'NO.198, 2ND Floor, Suite #944,\nCMH Road, Bangalore, Karnataka- 560038',
          ),

          const SizedBox(height: 32),

          // Email section
          _buildContactItem(
            icon: Icons.email_outlined,
            label: l10n.email,
            content: 'contact@petrasoftsolutions.com',
          ),

          const SizedBox(height: 32),

          // Phone numbers section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.phoneNumbers, style: labelTextStyle),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(
                  left: 28,
                ), // Align with text after icon
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+91 95388 73747',
                      key: const Key('getHelpPhone_0'),
                      style: contactTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+91 97399 99417',
                      key: const Key('getHelpPhone_1'),
                      style: contactTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Logo and company name section
          Center(
            child: PetrasoftBranding(
              key: const Key('getHelpBranding'),
              logoSize: 42.0,
              spacing: 8.0,
              companyNameStyle: companyNameStyle,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
