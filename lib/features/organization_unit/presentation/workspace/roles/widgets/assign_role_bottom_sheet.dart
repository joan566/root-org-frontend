import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';

/// Selector de rol departamental -- lista todos los roles del tenant (ADR-021:
/// el rol ya no tiene un alcance fijo, cualquier `Role` es asignable a nivel
/// de unidad).
class AssignRoleBottomSheet extends StatelessWidget {
  final List<Role> roles;

  const AssignRoleBottomSheet({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xxl),
      decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Asignar rol departamental', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            if (roles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  'No hay roles departamentales configurados en esta organización.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: roles.length,
                  itemBuilder: (_, index) {
                    final role = roles[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(role.name, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                      subtitle: role.description.isEmpty
                          ? null
                          : Text(role.description, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
                      onTap: () => Navigator.pop(context, role),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
