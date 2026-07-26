import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Construye los `ThemeData` reales de Flutter a partir de cada [AppPalette],
/// para que los widgets nativos de Material (Checkbox, AlertDialog, SnackBar,
/// DatePicker, etc.) respondan a modo claro/oscuro automaticamente sin tocarlos
/// uno por uno. Ver docs/00-core/08-theming/ADR-013-modo-oscuro.md.
class AppTheme {
  const AppTheme._();

  static ThemeData light = _build(AppPalette.light);
  static ThemeData dark = _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final colorScheme = ColorScheme(
      brightness: palette.brightness,
      primary: palette.primary,
      onPrimary: palette.isDark ? palette.slateDark : Colors.white,
      secondary: palette.primary,
      onSecondary: palette.isDark ? palette.slateDark : Colors.white,
      error: palette.error,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return palette.border;
          if (states.contains(WidgetState.selected)) return palette.primary;
          return Colors.transparent;
        }),
        side: BorderSide(color: palette.border, width: 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.isDark ? palette.surface : palette.slateDark,
        contentTextStyle: TextStyle(color: palette.isDark ? palette.textPrimary : Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.isDark ? palette.background : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.borderFocus, width: 1.5),
        ),
      ),
    );
  }
}
