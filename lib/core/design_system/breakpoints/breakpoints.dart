import 'package:flutter/widgets.dart';

/// Puntos de corte estandar del proyecto (ver
/// docs/00-core/07-refactor-arquitectura-frontend/04-estrategia-responsive.md).
///
/// Uso para pantallas NUEVAS o para quien decida unificar una pantalla
/// existente. Las pantallas con layout dual ya implementadas antes de esta
/// clase (login, register, create_tenant) mantienen su propio umbral
/// historico (ver ADR-012-plan-migracion.md, seccion de riesgos) hasta que
/// se decida explicitamente unificarlas.
class Breakpoints {
  const Breakpoints._();

  static const double mobileMax = 600;
  static const double desktopMin = 1024;

  static bool isMobile(double width) => width < mobileMax;

  static bool isTablet(double width) => width >= mobileMax && width < desktopMin;

  static bool isDesktop(double width) => width >= desktopMin;

  static bool isDesktopContext(BuildContext context) =>
      isDesktop(MediaQuery.sizeOf(context).width);
}
