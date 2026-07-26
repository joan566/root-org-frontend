import 'package:flutter/material.dart';

/// Una sección de navegación principal del shell (ej. "Organización").
/// `route` es la ruta que se navega al tocar la sección desde cero;
/// `relatedRoutes` son otras rutas internas que deben mantener esa misma
/// sección resaltada (ej. Configuración también cubre cambio de contraseña).
class ShellSection {
  final String label;
  final IconData icon;
  final String route;
  final List<String> relatedRoutes;

  const ShellSection({
    required this.label,
    required this.icon,
    required this.route,
    this.relatedRoutes = const [],
  });

  bool matchesRoute(String? routeName) {
    if (routeName == null) return false;
    return routeName == route || relatedRoutes.contains(routeName);
  }
}
