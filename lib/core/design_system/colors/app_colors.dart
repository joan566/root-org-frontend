import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppColors {
  static final ColorScheme light =
      ColorScheme.fromSeed(
        seedColor: AppPalette.brandGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppPalette.brandGreen,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD4EAE2),
        onPrimaryContainer: const Color(0xFF103B30),
        secondary: AppPalette.brandAmber,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF6E2B8),
        onSecondaryContainer: const Color(0xFF4A3100),
        surface: AppPalette.warmWhite,
        onSurface: AppPalette.warmBlack,
        error: AppPalette.error,
        onError: Colors.white,
      );

  static final ColorScheme dark =
      ColorScheme.fromSeed(
        seedColor: AppPalette.brandGreenLight,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppPalette.brandGreenLight,
        onPrimary: const Color(0xFF00382B),
        primaryContainer: const Color(0xFF285044),
        onPrimaryContainer: const Color(0xFFD4EAE2),
        secondary: AppPalette.brandAmberLight,
        onSecondary: const Color(0xFF472C00),
        secondaryContainer: const Color(0xFF654300),
        onSecondaryContainer: const Color(0xFFFFDEA6),
        surface: AppPalette.darkSurface,
        onSurface: const Color(0xFFE2E3DD),
        surfaceContainerHighest: AppPalette.darkSurfaceVariant,
        error: AppPalette.errorDark,
        onError: const Color(0xFF690005),
      );
}
