import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Fila de un integrante del departamento. `OrganizationUnitMemberInfo` no
/// trae foto ni "cargo dentro del departamento" -- se usa avatar de
/// iniciales y solo nombre + estado, ver adaptaciones del plan de
/// Estructura Organizacional.
class MemberRow extends StatelessWidget {
  final TenantMember member;
  final bool isActive;
  final bool isManager;
  final bool canRemove;
  final VoidCallback onViewProfile;
  final VoidCallback onRemove;

  const MemberRow({
    super.key,
    required this.member,
    required this.isActive,
    required this.isManager,
    this.canRemove = true,
    required this.onViewProfile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (isManager) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.badge_rounded, size: 14, color: colors.primary),
                    ],
                  ],
                ),
                Text(
                  isActive ? 'Activo' : 'Inactivo',
                  style: AppTypography.labelSmall.copyWith(color: isActive ? colors.success : colors.textMuted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => value == 'profile' ? onViewProfile() : onRemove(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: Text('Ver perfil')),
              if (canRemove) const PopupMenuItem(value: 'remove', child: Text('Remover del departamento')),
            ],
            icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
