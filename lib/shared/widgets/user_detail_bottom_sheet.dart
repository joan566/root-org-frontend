import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Detalle de un miembro (ver docs/01-features/organizacion.md). Fecha de
/// ingreso/último acceso se muestran como "No disponible" -- no vienen en
/// `GET /tenant/{id}/users`, así que no se inventan. "Actividad reciente"
/// usa el mismo estado vacío honesto que `DashboardActivityCard`: no existe
/// backend de auditoría por usuario todavía.
class UserDetailBottomSheet extends StatelessWidget {
  final TenantMember member;

  const UserDetailBottomSheet({super.key, required this.member});

  String get _initial => member.name.trim().isEmpty ? '?' : member.name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bool isActive = member.status.toUpperCase() == 'ACTIVE';

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl),
      decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primaryLight,
                  child: Text(_initial, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        member.roles.isEmpty ? 'Sin rol' : member.roles.join(', '),
                        style: AppTypography.labelMedium.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isActive ? colors.success : colors.textMuted).withOpacity(0.12),
                    borderRadius: AppRadius.borderPill,
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(color: isActive ? colors.success : colors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _InfoRow(icon: Icons.email_outlined, label: 'Correo electrónico', value: member.email, colors: colors),
            _InfoRow(icon: Icons.event_available_outlined, label: 'Fecha de ingreso', value: 'No disponible', colors: colors, muted: true),
            _InfoRow(icon: Icons.access_time_rounded, label: 'Último acceso', value: 'No disponible', colors: colors, muted: true),
            const SizedBox(height: AppSpacing.xl),
            Text('Actividad reciente', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderPill),
                      child: Icon(Icons.history_outlined, color: colors.textMuted, size: 24),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Aún no hay actividad registrada',
                      style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Los eventos de este miembro aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppPalette colors;
  final bool muted;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.colors, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: muted ? colors.textMuted : colors.textPrimary,
                    fontWeight: muted ? FontWeight.w500 : FontWeight.w600,
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
