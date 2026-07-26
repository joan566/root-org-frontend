import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/shared/widgets/base_container_card.dart';

/// Pestaña "Información" de Organización — solo lectura (ver
/// docs/frontend-navigation-redesign.md §3.1: `Tenant.name/description/code`
/// ya llegan en la sesión, pero no hay endpoint de actualización todavía,
/// así que no se agrega edición aquí).
class OrganizationInfoTab extends StatelessWidget {
  const OrganizationInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenants = context.watch<AuthProvider>().session?.user.tenants ?? [];
    final activeTenant = context.watch<TenantSessionController>().resolveActive(tenants);

    if (activeTenant == null) {
      return Center(
        child: Text(
          'No hay una organización activa.',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    final tenant = activeTenant.tenant;
    final roles = activeTenant.roles.isEmpty ? 'Sin rol' : activeTenant.roles.join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseContainerCard(
            title: 'Información general',
            icon: Icons.apartment_rounded,
            children: [
              _InfoRow(label: 'Nombre', value: tenant.name, icon: Icons.business_rounded),
              Divider(color: colors.border, height: 1),
              _InfoRow(
                label: 'Descripción',
                value: tenant.description.isEmpty ? 'Sin descripción registrada' : tenant.description,
                icon: Icons.description_outlined,
              ),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Código de invitación', value: tenant.code, icon: Icons.key_rounded),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Tu rol aquí', value: roles, icon: Icons.badge_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Esta información es de solo lectura por ahora. La edición estará disponible cuando el backend soporte actualizar los datos de la organización.',
                    style: AppTypography.labelSmall.copyWith(color: colors.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
