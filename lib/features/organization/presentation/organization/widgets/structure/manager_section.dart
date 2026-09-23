import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Sección "Encargado" del detalle de departamento. Asignar exige que el
/// usuario ya sea integrante ACTIVE de la unidad (RN-ORG-008) -- por eso
/// [onAssign] solo debe habilitarse cuando existan miembros activos
/// ([hasActiveMembers]).
class ManagerSection extends StatelessWidget {
  final TenantMember? manager;
  final bool hasActiveMembers;
  final VoidCallback onAssign;
  final VoidCallback onRemove;

  const ManagerSection({
    super.key,
    required this.manager,
    required this.hasActiveMembers,
    required this.onAssign,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Encargado', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          if (manager != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primaryLight,
                  child: Text(
                    manager!.name.isEmpty ? '?' : manager!.name[0].toUpperCase(),
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manager!.fullName, style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                      Text('Administrador del departamento', style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAssign,
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
                    child: const Text('Cambiar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.danger,
                      side: BorderSide(color: colors.danger),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                    ),
                    child: const Text('Remover'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: colors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Sin encargado asignado', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: hasActiveMembers ? onAssign : null,
                style: FilledButton.styleFrom(backgroundColor: colors.primary, shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
                child: const Text('Asignar encargado'),
              ),
            ),
            if (!hasActiveMembers) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Agrega miembros primero para poder asignarlos como encargado.',
                style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
