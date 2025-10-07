import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petrasoft_school_management_solutions/flavors.dart';

/// A reusable widget for displaying Petrasoft branding (logo + company name)
class PetrasoftBranding extends StatelessWidget {
  final double? logoSize;
  final double? spacing;
  final TextStyle? companyNameStyle;
  final bool showCompanyName;
  final BorderRadius? logoBorderRadius;

  const PetrasoftBranding({
    super.key,
    this.logoSize,
    this.spacing,
    this.companyNameStyle,
    this.showCompanyName = true,
    this.logoBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultCompanyNameStyle =
        companyNameStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );

    return Column(
      key: const Key('brandingColumn'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: logoBorderRadius ?? BorderRadius.circular(10.0),
          child: SvgPicture.asset(
            "assets/${F.appFlavor.name}/logo.svg",
            key: const Key('brandingLogo'),
            height: logoSize ?? 42.0,
          ),
        ),
        if (showCompanyName) ...[
          SizedBox(height: spacing ?? 8.0),
          Text(
            'Petrasoft Solutions',
            key: const Key('brandingCompanyName'),
            style: defaultCompanyNameStyle,
          ),
        ],
      ],
    );
  }
}
