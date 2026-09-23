import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Fila de un integrante para la pestaña de roles departamentales -- misma
/// estructura visual que `MemberRow`, pero el estado que importa aquí es el
/// rol asignado, no si está activo.
class RoleMemberRow extends StatelessWidget {
  final TenantMember member;
  final String? roleName;
  final bool canManage;
  final VoidCallback onAssign;
  final VoidCallback onRemove;

  const RoleMemberRow({
    super.key,
    required this.member,
    required this.roleName,
    required this.canManage,
    required this.onAssign,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasRole = roleName != null && roleName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: colors.flatCardDecoration(radius: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryLight,
            child: Text(
              member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                Text(
                  hasRole ? roleName! : 'Sin rol departamental',
                  style: AppTypography.labelSmall.copyWith(color: hasRole ? colors.primary : colors.textMuted),
                ),
              ],
            ),
          ),
          if (canManage)
            TextButton(
              onPressed: hasRole ? onRemove : onAssign,
              child: Text(hasRole ? 'Quitar' : 'Asignar'),
            ),
        ],
      ),
    );
  }
}
