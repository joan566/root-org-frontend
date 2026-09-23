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
import 'widgets/organization_status_banner.dart';
import 'widgets/quick_actions_row.dart';

/// Vista desktop del Dashboard General (ver
/// docs/01-features/panel-principal.md), rediseñada con identidad SaaS
/// premium (Notion/Linear/Stripe): tarjetas planas, azul como color
/// primario, sin gradientes ni glassmorphism pesado. El header/avatar/
/// selector de organización ya los cubre `ShellHeader` -- esta vista solo
/// compone el contenido bajo el header del shell.
class DashboardGeneralDesktopView extends StatelessWidget {
  final String userName;
  final bool hasOrganizations;
  final UserTenant? activeTenant;
  final int totalOrganizations;
  final String activeRoleLabel;
  final VoidCallback onCreateOrganization;
  final VoidCallback onJoinOrganization;

  const DashboardGeneralDesktopView({
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: !hasOrganizations
              ? NoActiveOrganizationView(
                  onCreateOrganization: onCreateOrganization,
                  onJoinOrganization: onJoinOrganization,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrganizationStatusBanner(
                      activeTenant: activeTenant!,
                      totalOrganizations: totalOrganizations,
                      activeRoleLabel: activeRoleLabel,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Dashboard General', style: AppTypography.headlineSmall.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido nuevamente, $userName. Aquí tienes un resumen del estado actual de tu organización.',
                      style: AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Módulos activos', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: AppSpacing.lg),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.xl,
                        crossAxisSpacing: AppSpacing.xl,
                        // Alto fijo (no childAspectRatio): el contenido de la
                        // tarjeta (icono+badge, título, descripción de 2
                        // líneas, CTA) necesita una altura mínima constante
                        // sin importar el ancho disponible -- con
                        // childAspectRatio, ventanas angostas (cerca de
                        // Breakpoints.desktopMin) encogían la tarjeta lo
                        // suficiente para desbordar el contenido. Medido con
                        // getMaxIntrinsicHeight: ~212px en tarjetas anchas
                        // (viewport ancho) y hasta ~238px cerca de
                        // Breakpoints.desktopMin (1024px), donde la tarjeta
                        // se angosta a 2 columnas y el título/descripción
                        // envuelven a más líneas. 250 cubre el peor caso con
                        // margen para la diferencia de métricas de fuente
                        // entre el test y el render real (ver nota en
                        // test/widget_test.dart).
                        mainAxisExtent: 250,
                      ),
                      itemCount: moduleCatalog.length,
                      itemBuilder: (context, index) {
                        final module = moduleCatalog[index];
                        return ModuleSummaryCard(
                          icon: module.icon,
                          title: module.title,
                          description: module.description,
                          accentColor: resolveModuleAccent(colors, module.colorKey),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(child: DashboardActivityCard()),
                          SizedBox(width: AppSpacing.xl),
                          Expanded(child: DashboardPendingCard()),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const QuickActionsRow(),
                  ],
                ),
        ),
      ),
    );
  }
}
