import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'package:savings_api_frontend/shared/layouts/coming_soon_screen.dart';

/// Rutas placeholder para secciones cuya feature real todavía no existe
/// (Módulos/Administración — ver docs/frontend-navigation-redesign.md §3).
/// Se registran aquí, en `shell/`, en vez de crear features vacías por
/// adelantado; cuando cada una tenga su propia feature (Fase 4), su
/// `*_routes.dart` reemplaza la entrada correspondiente y esta función deja
/// de registrarla. Organización ya tiene su propia feature desde la Fase 3
/// (`organization_routes.dart`).
void registerShellPlaceholderRoutes() {
  RouteRegistry.instance.register(
    AppRoutes.modules,
    (_) => const ComingSoonScreen(
      title: 'Módulos',
      description:
          'Gestión Financiera, Préstamos, Inventario y Actividades se irán activando aquí a medida que cada uno tenga su propio backend.',
      icon: Icons.widgets_rounded,
    ),
  );

  RouteRegistry.instance.register(
    AppRoutes.administration,
    (_) => const ComingSoonScreen(
      title: 'Administración',
      description: 'Auditoría, integraciones y herramientas administrativas llegarán en una fase posterior.',
      icon: Icons.admin_panel_settings_rounded,
    ),
  );
}
