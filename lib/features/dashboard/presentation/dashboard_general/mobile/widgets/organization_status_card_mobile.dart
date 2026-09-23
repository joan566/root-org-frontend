import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

/// Versión vertical (mobile) de `OrganizationStatusBanner` (desktop) -- misma
/// información honesta, apilada en vez de en una fila ancha: nombre,
/// descripción, badge de estado, y 3 stats reales (organizaciones, rol
/// activo, código). Sin donut/gráfico de "% adopción de módulos": no existe
/// ese dato hoy, mismo criterio que la vista desktop (ver
/// docs/01-features/panel-principal.md).
class OrganizationStatusCardMobile extends StatelessWidget {
  final UserTenant activeTenant;
  final int totalOrganizations;
  final String activeRoleLabel;

  const OrganizationStatusCardMobile({
    super.key,
    required this.activeTenant,
    required this.totalOrganizations,
    required this.activeRoleLabel,
  });

  String _initial() {
    final name = activeTenant.tenant.name.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bool isActive = activeTenant.status.toUpperCase() == 'ACTIVE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.primaryLight, borderRadius: AppRadius.borderMd),
                child: Text(_initial(), style: AppTypography.titleLarge.copyWith(color: colors.primary)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  activeTenant.tenant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? colors.success : colors.textMuted).withOpacity(0.12),
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  isActive ? 'Activa' : activeTenant.status,
                  style: TextStyle(
                    color: isActive ? colors.success : colors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (activeTenant.tenant.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              activeTenant.tenant.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.md,
            children: [
              _StatColumn(label: 'Organizaciones', value: '$totalOrganizations', colors: colors),
              _StatColumn(label: 'Rol activo', value: activeRoleLabel, colors: colors),
              _StatColumn(label: 'Código', value: activeTenant.tenant.code, colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final AppPalette colors;

  const _StatColumn({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
