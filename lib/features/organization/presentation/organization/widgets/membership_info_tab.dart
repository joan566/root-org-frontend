import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/shared/widgets/base_container_card.dart';

/// Pestaña "Mi membresía" de Organización — visible solo para usuarios
/// Member (ver docs/01-features/organizacion.md). Muestra la relación del
/// usuario con la organización activa usando solo datos que ya existen en
/// la sesión (`UserTenant`/`User`); no incluye "Miembro desde" ni
/// "Departamentos" porque ningún endpoint actual expone esa información
/// todavía (no inventamos datos).
class MembershipInfoTab extends StatelessWidget {
  const MembershipInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = context.watch<AuthProvider>().session?.user;
    final tenants = user?.tenants ?? [];
    final activeTenant = context.watch<TenantSessionController>().resolveActive(tenants);

    if (user == null || activeTenant == null) {
      return Center(
        child: Text(
          'No hay una organización activa.',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      );
    }

    final fullName = [user.name, user.lastName].where((p) => p != null && p.isNotEmpty).join(' ');
    final roles = activeTenant.roles.isEmpty ? 'Sin rol' : activeTenant.roles.join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseContainerCard(
            title: 'Mi membresía',
            icon: Icons.badge_outlined,
            children: [
              _InfoRow(label: 'Usuario', value: fullName.isEmpty ? user.email : fullName, icon: Icons.person_outline_rounded),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Organización', value: activeTenant.tenant.name, icon: Icons.apartment_rounded),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Rol', value: roles, icon: Icons.shield_outlined),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Estado', value: activeTenant.status, icon: Icons.check_circle_outline_rounded),
              Divider(color: colors.border, height: 1),
              _InfoRow(label: 'Miembro desde', value: 'No disponible', icon: Icons.event_outlined),
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
                    'Tus departamentos aparecerán aquí cuando la organización tenga estructura interna disponible.',
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
