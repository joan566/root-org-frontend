import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_palette.dart';
import 'theme_controller.dart';

/// Punto de acceso a los colores de la app. Resuelve a [AppPalette.light] o
/// [AppPalette.dark] segun la preferencia del usuario (`ThemeController`) y,
/// si esta en modo "sistema", segun el brillo actual del sistema operativo.
///
/// Uso: `final colors = AppColors.of(context);` una vez al inicio del
/// widget/metodo que construye UI, y luego `colors.primary`, `colors.surface`,
/// etc. Requiere que el `BuildContext` este dentro del `ChangeNotifierProvider`
/// de `ThemeController` (montado en `main.dart`).
///
/// Ver docs/00-core/08-theming/ADR-013-modo-oscuro.md.
class AppColors {
  const AppColors._();

  static AppPalette of(BuildContext context) {
    final mode = context.watch<ThemeController>().mode;

    switch (mode) {
      case ThemeMode.light:
        return AppPalette.light;
      case ThemeMode.dark:
        return AppPalette.dark;
      case ThemeMode.system:
        final brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    }
  }
}
