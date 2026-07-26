/// Escala de espaciado del proyecto, formalizada a partir de los valores
/// ya usados de forma consistente en el codigo existente (ver
/// ADR-012-plan-migracion.md, Fase 7). Pensada para pantallas/widgets
/// nuevos: el codigo existente no se retroactiva en esta fase, sigue
/// usando valores literales.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}
