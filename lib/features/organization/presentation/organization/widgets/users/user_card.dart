import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Card de un miembro en la pestaña Usuarios (ver
/// docs/01-features/organizacion.md). Sin "Último acceso": no viene en
/// `GET /tenant/{id}/users` -- se omite en vez de inventarse.
class UserCard extends StatelessWidget {
  final TenantMember member;
  final VoidCallback onTap;
  final VoidCallback onRequestUnlink;

  const UserCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.onRequestUnlink,
  });

  String get _initial => member.name.trim().isEmpty ? '?' : member.name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bool isActive = member.status.toUpperCase() == 'ACTIVE';
    final String roleLabel = member.roles.isEmpty ? 'Sin rol' : member.roles.join(', ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: colors.flatCardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primaryLight,
                child: Text(_initial, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: colors.textMuted.withOpacity(0.12), borderRadius: AppRadius.borderPill),
                            child: Text('Inactivo', style: TextStyle(color: colors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabel,
                      style: AppTypography.labelMedium.copyWith(color: colors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              _OptionsButton(onRequestUnlink: onRequestUnlink),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsButton extends StatelessWidget {
  final VoidCallback onRequestUnlink;

  const _OptionsButton({required this.onRequestUnlink});

  Future<void> _openMenu(BuildContext context) async {
    final colors = AppColors.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(color: colors.surface, borderRadius: AppRadius.borderLg),
          child: SafeArea(
            top: false,
            child: ListTile(
              leading: Icon(Icons.link_off_rounded, color: colors.danger),
              title: Text('Desasociar usuario', style: TextStyle(color: colors.danger, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(sheetContext);
                onRequestUnlink();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      onPressed: () => _openMenu(context),
      icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
    );
  }
}
