import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Selector de encargado -- solo lista integrantes ya `ACTIVE` de la unidad,
/// porque el backend exige eso para asignar (RN-ORG-008).
class AssignManagerBottomSheet extends StatelessWidget {
  final List<TenantMember> activeMembers;

  const AssignManagerBottomSheet({super.key, required this.activeMembers});

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
            Text('Asignar encargado', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activeMembers.length,
                itemBuilder: (_, index) {
                  final member = activeMembers[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colors.primaryLight,
                      child: Text(member.name.isEmpty ? '?' : member.name[0].toUpperCase(), style: TextStyle(color: colors.primary)),
                    ),
                    title: Text(member.fullName, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                    onTap: () => Navigator.pop(context, member.userId),
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
