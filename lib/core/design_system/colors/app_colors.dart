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

  /// [listen] controla si el widget que llama se resuscribe a cambios de
  /// tema (`context.watch`, el default -- solo valido durante `build()`) o
  /// simplemente lee el valor actual sin resuscribirse (`context.read`,
  /// `listen: false`) -- necesario para llamar `AppColors.of` desde un
  /// callback (`onTap`/`onPressed`) en vez de un `build()`, ej. para armar
  /// un color antes de `showDialog`/`showModalBottomSheet`/`showDatePicker`.
  static AppPalette of(BuildContext context, {bool listen = true}) {
    final mode = listen ? context.watch<ThemeController>().mode : context.read<ThemeController>().mode;

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
