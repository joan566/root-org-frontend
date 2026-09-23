import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';

/// Una acción rápida real del dashboard (mismas 6 desde siempre: Mis
/// organizaciones, Editar perfil, Seguridad, Crear organización, Unirse por
/// código, Configuración). Compartido entre `desktop/widgets/quick_actions_row.dart`
/// y `mobile/widgets/quick_actions_fab.dart` para no duplicar el catálogo.
class QuickActionSpec {
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const QuickActionSpec({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
  });
}

const List<QuickActionSpec> quickActionsCatalog = [
  QuickActionSpec(
    icon: Icons.corporate_fare_rounded,
    title: 'Mis organizaciones',
    description: 'Ver y administrar tus organizaciones',
    route: AppRoutes.tenants,
  ),
  QuickActionSpec(
    icon: Icons.person_outline_rounded,
    title: 'Editar perfil',
    description: 'Actualiza tu información personal',
    route: AppRoutes.profile,
  ),
  QuickActionSpec(
    icon: Icons.shield_outlined,
    title: 'Seguridad',
    description: 'Contraseña y verificación de la cuenta',
    route: AppRoutes.profile,
  ),
  QuickActionSpec(
    icon: Icons.add_box_outlined,
    title: 'Crear organización',
    description: 'Inicia una nueva organización',
    route: AppRoutes.createTenant,
  ),
  QuickActionSpec(
    icon: Icons.qr_code_scanner_rounded,
    title: 'Unirse por código',
    description: 'Únete usando un código de invitación',
    route: AppRoutes.joinTenant,
  ),
  QuickActionSpec(
    icon: Icons.tune_rounded,
    title: 'Configuración',
    description: 'Preferencias generales de tu cuenta',
    route: AppRoutes.profile,
  ),
];

/// Navega a la ruta de la acción, evitando duplicar la pantalla actual en la
/// pila (mismo patrón que ya usaban `QuickActionsGrid`/`QuickActionsRow`).
void navigateToQuickAction(BuildContext context, QuickActionSpec action) {
  final currentRouteName = ModalRoute.of(context)?.settings.name;
  if (currentRouteName == action.route) return;
  Navigator.of(context).pushNamedAndRemoveUntil(action.route, (r) => r.isFirst);
}
