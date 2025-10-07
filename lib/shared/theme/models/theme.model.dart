import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xFF7243D8),
      onPrimary: Color(0xFFFDFCFF),
      secondary: Color(0xFFF4307F),
      onSecondary: Color(0xFFFDFCFF),
      error: Color(0xFFF4307F),
      onError: Color(0xFFFDFCFF),
      background: Color(0xFFFDFCFF),
      onBackground: Color(0xFF000047),
      surface: Color(0xFFF6F2FF),
      onSurface: Color(0xFF262647),
      surfaceVariant: Color(0xFFFDFCFF),
      onSurfaceVariant: Color(0xFF000047),
      outline: Color(0xFF8989A3),
      scrim: Color(0xFF000023),
      inverseSurface: Color(0xFFFDFCFF),
      inverseOnSurface: Color(0xFF484856),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7243D8),
      onPrimary: Color(0xFFFDFCFF),
      secondary: Color(0xFFF4307F),
      onSecondary: Color(0xFFFDFCFF),
      error: Color(0xFFF4307F),
      onError: Color(0xFFFDFCFF),
      background: Color(0xFF000023),
      onBackground: Color(0xFFFDFCFF),
      surface: Color(0xFF00002D),
      onSurface: Color(0xFFFDFCFF),
      surfaceVariant: Color(0xFF000047),
      onSurfaceVariant: Color(0xFFFDFCFF),
      outline: Color(0xFFAAA2BC),
      scrim: Color(0xFFFDFCFF),
      inverseSurface: Color(0xFF262647),
      inverseOnSurface: Color(0xFFFDFCFF),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    this.surfaceTint,
    this.primaryContainer,
    this.onPrimaryContainer,
    this.secondaryContainer,
    this.onSecondaryContainer,
    this.tertiary,
    this.onTertiary,
    this.tertiaryContainer,
    this.onTertiaryContainer,
    this.errorContainer,
    this.onErrorContainer,
    this.outlineVariant,
    this.shadow,
    this.inversePrimary,
    this.primaryFixed,
    this.onPrimaryFixed,
    this.primaryFixedDim,
    this.onPrimaryFixedVariant,
    this.secondaryFixed,
    this.onSecondaryFixed,
    this.secondaryFixedDim,
    this.onSecondaryFixedVariant,
    this.tertiaryFixed,
    this.onTertiaryFixed,
    this.tertiaryFixedDim,
    this.onTertiaryFixedVariant,
    this.surfaceDim,
    this.surfaceBright,
    this.surfaceContainerLowest,
    this.surfaceContainerLow,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color? surfaceTint;
  final Color? primaryContainer;
  final Color? onPrimaryContainer;
  final Color? secondaryContainer;
  final Color? onSecondaryContainer;
  final Color? tertiary;
  final Color? onTertiary;
  final Color? tertiaryContainer;
  final Color? onTertiaryContainer;
  final Color? errorContainer;
  final Color? onErrorContainer;
  final Color? outlineVariant;
  final Color? shadow;
  final Color? inversePrimary;
  final Color? primaryFixed;
  final Color? onPrimaryFixed;
  final Color? primaryFixedDim;
  final Color? onPrimaryFixedVariant;
  final Color? secondaryFixed;
  final Color? onSecondaryFixed;
  final Color? secondaryFixedDim;
  final Color? onSecondaryFixedVariant;
  final Color? tertiaryFixed;
  final Color? onTertiaryFixed;
  final Color? tertiaryFixedDim;
  final Color? onTertiaryFixedVariant;
  final Color? surfaceDim;
  final Color? surfaceBright;
  final Color? surfaceContainerLowest;
  final Color? surfaceContainerLow;
  final Color? surfaceContainer;
  final Color? surfaceContainerHigh;
  final Color? surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
