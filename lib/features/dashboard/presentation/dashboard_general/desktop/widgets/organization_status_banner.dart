import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

/// Tarjeta horizontal con el estado de la organización activa. Solo muestra
/// datos reales (`UserTenant`/`Tenant`) -- sin "Departamentos", "% de
/// adopción de módulos" ni "última actividad": no existe backend para eso
/// hoy y este proyecto evita inventar métricas (ver
/// docs/01-features/panel-principal.md).
class OrganizationStatusBanner extends StatelessWidget {
  final UserTenant activeTenant;
  final int totalOrganizations;
  final String activeRoleLabel;

  const OrganizationStatusBanner({
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: colors.flatCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.primaryLight, borderRadius: AppRadius.borderLg),
            child: Text(
              _initial(),
              style: AppTypography.headlineSmall.copyWith(color: colors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        activeTenant.tenant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (activeTenant.tenant.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activeTenant.tenant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.xxl,
                  runSpacing: AppSpacing.lg,
                  children: [
                    _StatColumn(label: 'Organizaciones', value: '$totalOrganizations', colors: colors),
                    _StatColumn(label: 'Rol activo', value: activeRoleLabel, colors: colors),
                    _StatColumn(label: 'Código', value: activeTenant.tenant.code, colors: colors),
                  ],
                ),
              ],
            ),
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
