import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

import '../widgets/dashboard_activity_card.dart';
import '../widgets/dashboard_pending_card.dart';
import '../widgets/module_catalog.dart';
import '../widgets/module_summary_card.dart';
import '../widgets/no_active_organization_card.dart';
import 'widgets/organization_status_card_mobile.dart';

/// Vista mobile del Dashboard General (ver docs/01-features/panel-principal.md
/// §"Vista mobile"), mismo lenguaje visual SaaS premium plano que la vista
/// desktop (`dashboard_general_desktop_view.dart`): tarjetas planas, mismos
/// colores de identidad por módulo, misma regla de honestidad (sin métricas
/// inventadas). El header/FAB de acciones rápidas los cubre
/// `DashboardGeneralScreen` -- esta vista solo compone el contenido que va
/// dentro del scroll.
class DashboardGeneralMobileView extends StatelessWidget {
  final String userName;
  final bool hasOrganizations;
  final UserTenant? activeTenant;
  final int totalOrganizations;
  final String activeRoleLabel;
  final VoidCallback onCreateOrganization;
  final VoidCallback onJoinOrganization;

  const DashboardGeneralMobileView({
    super.key,
    required this.userName,
    required this.hasOrganizations,
    required this.activeTenant,
    required this.totalOrganizations,
    required this.activeRoleLabel,
    required this.onCreateOrganization,
    required this.onJoinOrganization,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (!hasOrganizations) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: NoActiveOrganizationView(
          onCreateOrganization: onCreateOrganization,
          onJoinOrganization: onJoinOrganization,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrganizationStatusCardMobile(
            activeTenant: activeTenant!,
            totalOrganizations: totalOrganizations,
            activeRoleLabel: activeRoleLabel,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Dashboard General', style: AppTypography.headlineSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Bienvenido nuevamente, $userName. Aquí tienes el estado actual de tu organización.',
            style: AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Módulos activos', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.lg),
          // Columna simple (no grid): cada tarjeta ocupa todo el ancho y se
          // dimensiona a su contenido natural -- sin altura fija que medir
          // ni riesgo de overflow al angostarse (ver la vuelta de
          // `mainAxisExtent` que sí hizo falta en el grid 2x2 de desktop).
          for (final module in moduleCatalog)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: ModuleSummaryCard(
                icon: module.icon,
                title: module.title,
                description: module.description,
                accentColor: resolveModuleAccent(colors, module.colorKey),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          const DashboardActivityCard(),
          const SizedBox(height: AppSpacing.xl),
          const DashboardPendingCard(),
        ],
      ),
    );
  }
}
