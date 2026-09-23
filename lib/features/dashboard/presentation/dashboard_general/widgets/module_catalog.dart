import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';

/// Un módulo del mapa de navegación (ver docs/01-features/panel-principal.md
/// §"Vista desktop"/"Vista mobile"). Ninguno tiene backend propio todavía,
/// así que solo lleva icono/título/descripción honesta + color de
/// identidad -- nunca métricas inventadas. Compartido entre
/// `desktop/dashboard_general_desktop_view.dart` y
/// `mobile/dashboard_general_mobile_view.dart` para no duplicar el catálogo.
class ModuleSpec {
  final IconData icon;
  final String title;
  final String description;

  /// Clave del color de identidad -- ver [resolveModuleAccent].
  final String colorKey;

  const ModuleSpec({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorKey,
  });
}

const List<ModuleSpec> moduleCatalog = [
  ModuleSpec(
    icon: Icons.account_balance_wallet_outlined,
    title: 'Gestión Financiera',
    description: 'Movimientos, períodos, balances y reportes.',
    colorKey: 'primary',
  ),
  ModuleSpec(
    icon: Icons.inventory_2_outlined,
    title: 'Inventario',
    description: 'Productos registrados y alertas de stock.',
    colorKey: 'warning',
  ),
  ModuleSpec(
    icon: Icons.event_note_outlined,
    title: 'Actividades',
    description: 'Eventos y tareas de la organización.',
    colorKey: 'secondary',
  ),
  ModuleSpec(
    icon: Icons.request_quote_outlined,
    title: 'Gestión de Préstamos',
    description: 'Solicitudes, cuotas y seguimiento de cartera.',
    colorKey: 'success',
  ),
];

/// Color de identidad por módulo -- reutiliza tokens ya existentes de
/// `AppPalette` (`primary`/`warning`/`secondary`/`success`) en vez de
/// definir colores nuevos solo para este propósito decorativo.
Color resolveModuleAccent(AppPalette colors, String key) {
  switch (key) {
    case 'warning':
      return colors.warning;
    case 'secondary':
      return colors.secondary;
    case 'success':
      return colors.success;
    default:
      return colors.primary;
  }
}
