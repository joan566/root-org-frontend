import 'package:flutter/widgets.dart';

/// Escala de radios del proyecto, formalizada a partir de los valores ya
/// usados de forma consistente en el codigo existente (ver
/// ADR-012-plan-migracion.md, Fase 7). Pensada para pantallas/widgets
/// nuevos: el codigo existente no se retroactiva en esta fase.
class AppRadius {
  const AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Radio "pill" para elementos totalmente redondeados (search bars, badges).
  static const double pill = 100;

  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
}
