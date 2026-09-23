import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/breakpoints/breakpoints.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';

import 'desktop/dashboard_general_desktop_view.dart';
import 'mobile/dashboard_general_mobile_view.dart';
import 'mobile/widgets/quick_actions_fab.dart';

import '../../../auth/presentation/provider/auth_provider.dart';

/// Centro de control de la organización activa (ver
/// docs/frontend-navigation-redesign.md — Fase 2). Antes `PersonalDashboardScreen`.
class DashboardGeneralScreen extends StatefulWidget {
  const DashboardGeneralScreen({super.key});

  @override
  State<DashboardGeneralScreen> createState() => _DashboardGeneralScreenState();
}

class _DashboardGeneralScreenState extends State<DashboardGeneralScreen> {
  String _formatRoles(List<String> rawRoles) {
    if (rawRoles.isEmpty) return 'Ninguno';
    return rawRoles.map((rawRole) {
      switch (rawRole.toUpperCase()) {
        case 'OWNER':
          return 'Propietario';
        case 'ADMIN':
          return 'Admin';
        case 'MEMBER':
        case 'USER':
          return 'Colaborador';
        default:
          return rawRole;
      }
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;
    final tenantSession = context.watch<TenantSessionController>();

    final bool hasOrganizations = authProvider.session?.hasTenant ?? false;
    final tenantsList = currentUser?.tenants ?? [];
    final int totalOrgs = tenantsList.length;
    final activeTenant = tenantSession.resolveActive(tenantsList);

    final String activeRoleFormatted = _formatRoles(activeTenant?.roles ?? const []);

    if (Breakpoints.isDesktopContext(context)) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: DashboardGeneralDesktopView(
            userName: currentUser?.name ?? 'Usuario',
            hasOrganizations: hasOrganizations,
            activeTenant: activeTenant,
            totalOrganizations: totalOrgs,
            activeRoleLabel: activeRoleFormatted,
            onCreateOrganization: () => Navigator.pushNamed(context, AppRoutes.createTenant),
            onJoinOrganization: () => Navigator.pushNamed(context, AppRoutes.joinTenant),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: DashboardGeneralMobileView(
              userName: currentUser?.name ?? 'Usuario',
              hasOrganizations: hasOrganizations,
              activeTenant: activeTenant,
              totalOrganizations: totalOrgs,
              activeRoleLabel: activeRoleFormatted,
              onCreateOrganization: () => Navigator.pushNamed(context, AppRoutes.createTenant),
              onJoinOrganization: () => Navigator.pushNamed(context, AppRoutes.joinTenant),
            ),
          ),
          const Positioned.fill(child: QuickActionsFab()),
        ],
      ),
    );
  }
}
