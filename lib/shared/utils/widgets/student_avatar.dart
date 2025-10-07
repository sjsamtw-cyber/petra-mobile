import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StudentAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final int? genderId; // 1 = male, 2 = female
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const StudentAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.genderId,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fallbackTextColor = textColor ?? theme.colorScheme.onSurface;

    // Generate initials from student name
    String getInitials() {
      final trimmedFirstName = firstName.trim();
      final trimmedLastName = lastName.trim();

      if (trimmedFirstName.isEmpty && trimmedLastName.isEmpty) {
        return '?';
      }

      String initials = '';
      if (trimmedFirstName.isNotEmpty) {
        initials += trimmedFirstName[0].toUpperCase();
      }
      if (trimmedLastName.isNotEmpty) {
        initials += trimmedLastName[0].toUpperCase();
      }

      return initials;
    }

    return CircleAvatar(
      key: const Key('studentAvatarCircle'),
      radius: radius,
      backgroundColor: fallbackColor,
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty && photoUrl != 'na'
            ? CachedNetworkImage(
                key: const Key('studentAvatarNetworkImage'),
                imageUrl: photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: fallbackColor,
                  child: Center(
                    child: SizedBox(
                      width: radius * 0.6,
                      height: radius * 0.6,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          fallbackTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => genderId != null
                    ? Image.asset(
                        genderId == 1
                            ? 'assets/general/boy.png'
                            : 'assets/general/girl.png',
                        key: const Key('studentAvatarGenderImage'),
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        key: const Key('studentAvatarInitialsContainer'),
                        width: radius * 2,
                        height: radius * 2,
                        color: fallbackColor,
                        child: Center(
                          child: Text(
                            getInitials(),
                            key: const Key('studentAvatarInitialsText'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: fallbackTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: radius * 0.6,
                            ),
                          ),
                        ),
                      ),
              )
            : genderId != null
            ? Image.asset(
                genderId == 1
                    ? 'assets/general/boy.png'
                    : 'assets/general/girl.png',
                key: const Key('studentAvatarGenderImage'),
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              )
            : Container(
                key: const Key('studentAvatarInitialsContainer'),
                width: radius * 2,
                height: radius * 2,
                color: fallbackColor,
                child: Center(
                  child: Text(
                    getInitials(),
                    key: const Key('studentAvatarInitialsText'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fallbackTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: radius * 0.6,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Variant of StudentAvatar with additional indicator overlays
class StudentAvatarWithIndicator extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final int? genderId; // 1 = male, 2 = female
  final double radius;
  final Widget? indicator;
  final Color? backgroundColor;
  final Color? textColor;

  const StudentAvatarWithIndicator({
    super.key,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.genderId,
    this.radius = 24,
    this.indicator,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('studentAvatarWithIndicatorStack'),
      children: [
        StudentAvatar(
          firstName: firstName,
          lastName: lastName,
          photoUrl: photoUrl,
          genderId: genderId,
          radius: radius,
          backgroundColor: backgroundColor,
          textColor: textColor,
        ),
        if (indicator != null)
          Positioned(right: 0, bottom: 0, child: indicator!),
      ],
    );
  }
}
