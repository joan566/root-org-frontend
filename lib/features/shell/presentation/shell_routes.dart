import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'package:savings_api_frontend/shared/layouts/coming_soon_screen.dart';

/// Rutas placeholder para secciones cuya feature real todavía no existe
/// (Módulos — ver docs/frontend-navigation-redesign.md §3). Se registran
/// aquí, en `shell/`, en vez de crear features vacías por adelantado;
/// cuando la feature real exista, su `*_routes.dart` reemplaza la entrada
/// correspondiente y esta función deja de registrarla. Organización
/// (`organization_routes.dart`) y Administración
/// (`organization_unit_routes.dart`, ver docs/01-features/organizacion.md
/// §"Workspace") ya tienen su propia feature.
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
}
