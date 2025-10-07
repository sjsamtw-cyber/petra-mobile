import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_gender.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final UserGender? gender;
  final String fallbackText;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.gender,
    required this.fallbackText,
    this.radius = 32,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if we have a valid image URL
    if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != 'na') {
      return CircleAvatar(
        key: const Key('profileAvatarNetwork'),
        radius: radius,
        backgroundColor: backgroundColor ?? colorScheme.primary,
        child: ClipOval(
          child: CachedNetworkImage(
            key: const Key('profileAvatarNetworkImage'),
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                _buildFallbackAvatar(theme, colorScheme),
            errorWidget: (context, url, error) =>
                _buildFallbackAvatar(theme, colorScheme),
          ),
        ),
      );
    }

    // If no valid image URL, use fallback
    return _buildFallbackAvatar(theme, colorScheme);
  }

  Widget _buildFallbackAvatar(ThemeData theme, ColorScheme colorScheme) {
    // If we have gender information, use gender-based fallback images
    if (gender != null) {
      String assetPath;
      switch (gender!) {
        case UserGender.female:
          assetPath = 'assets/general/girl.png';
          break;
        case UserGender.male:
        default:
          assetPath = 'assets/general/boy.png';
          break;
      }

      return CircleAvatar(
        key: const Key('profileAvatarGender'),
        radius: radius,
        backgroundColor: backgroundColor ?? colorScheme.primary,
        child: ClipOval(
          child: Image.asset(
            assetPath,
            key: const Key('profileAvatarGenderImage'),
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildTextFallback(theme, colorScheme),
          ),
        ),
      );
    }

    // Final fallback: use text avatar
    return _buildTextFallback(theme, colorScheme);
  }

  Widget _buildTextFallback(ThemeData theme, ColorScheme colorScheme) {
    return CircleAvatar(
      key: const Key('profileAvatarText'),
      radius: radius,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
        key: const Key('profileAvatarTextValue'),
        style: theme.textTheme.headlineSmall?.copyWith(
          color: textColor ?? colorScheme.onPrimary,
          fontSize: radius * 0.6, // Scale text size with avatar size
        ),
      ),
    );
  }
}
