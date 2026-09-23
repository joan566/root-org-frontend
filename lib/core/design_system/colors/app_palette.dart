import 'package:flutter/material.dart';

/// Conjunto inmutable de colores para un modo (claro u oscuro). Es la unica
/// fuente de verdad para los valores de color de la app - ver
/// docs/00-core/08-theming/ADR-013-modo-oscuro.md.
class AppPalette {
  final Brightness brightness;

  // Marca (bloques decorativos, iguales en ambas paletas)
  final Color primaryDark;
  final Color slateDark;

  // Marca (se ajustan por paleta para mantener contraste/legibilidad)
  final Color primary;
  final Color primaryLight;
  final Color secondary;

  // Superficies
  final Color background;
  final Color surface;

  // Texto
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Bordes
  final Color border;
  final Color borderFocus;

  // Estados
  final Color success;
  final Color warning;
  final Color danger;
  final Color error;

  // Tarjeta de error de backend (fondo/texto sutil, no el rojo saturado de `error`)
  final Color errorSurface;
  final Color errorSurfaceText;

  // Base para sombras (BoxShadow.color se deriva de este con distintas opacidades)
  final Color shadowBase;

  const AppPalette({
    required this.brightness,
    required this.primaryDark,
    required this.slateDark,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderFocus,
    required this.success,
    required this.warning,
    required this.danger,
    required this.error,
    required this.errorSurface,
    required this.errorSurfaceText,
    required this.shadowBase,
  });

  bool get isDark => brightness == Brightness.dark;

  List<BoxShadow> premiumShadow() => [
    BoxShadow(
      color: shadowBase.withOpacity(isDark ? 0.32 : 0.04),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: shadowBase.withOpacity(isDark ? 0.18 : 0.02),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  List<BoxShadow> subtleShadow() => [
    BoxShadow(
      color: shadowBase.withOpacity(isDark ? 0.28 : 0.03),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: shadowBase.withOpacity(isDark ? 0.14 : 0.01),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  List<BoxShadow> floatingShadow() => [
    BoxShadow(
      color: shadowBase.withOpacity(isDark ? 0.4 : 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  BoxDecoration translucentCardDecoration({double radius = 24.0}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1.5),
      boxShadow: subtleShadow(),
      gradient: LinearGradient(
        colors: [surface, background.withOpacity(0.4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// Tarjeta blanca plana, estilo SaaS (Notion/Linear/Stripe): sin gradiente,
  /// solo borde sutil + sombra discreta. Distinta de [translucentCardDecoration]
  /// (que sigue usando el resto de la app) - pensada para el dashboard desktop.
  BoxDecoration flatCardDecoration({double radius = 20.0}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: subtleShadow(),
    );
  }

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    primaryDark: Color(0xFF1E3A8A),
    slateDark: Color(0xFF0F172A),
    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFFDBEAFE),
    secondary: Color(0xFF4F46E5),
    background: Color(0xFFF5F7FB),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFFE5E7EB),
    borderFocus: Color(0xFF2563EB),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    error: Color(0xFFEF4444),
    errorSurface: Color(0xFFFEF2F2),
    errorSurfaceText: Color(0xFF991B1B),
    shadowBase: Color(0xFF0F172A),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primaryDark: Color(0xFF1E3A8A),
    slateDark: Color(0xFF0F172A),
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF172554),
    secondary: Color(0xFF818CF8),
    background: Color(0xFF0B1220),
    surface: Color(0xFF151E2E),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    border: Color(0xFF263244),
    borderFocus: Color(0xFF3B82F6),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    error: Color(0xFFF87171),
    errorSurface: Color(0xFF2D1214),
    errorSurfaceText: Color(0xFFFCA5A5),
    shadowBase: Color(0xFF000000),
  );
}
