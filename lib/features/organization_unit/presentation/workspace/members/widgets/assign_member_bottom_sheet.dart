import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

/// Selector de usuario a agregar como integrante -- lista miembros del
/// tenant que todavía no son integrantes activos de esta unidad. La
/// asignación es directa (`POST /organization-units/{id}/members`), no un
/// flujo de solicitudes.
class AssignMemberBottomSheet extends StatelessWidget {
  final List<TenantMember> candidates;

  const AssignMemberBottomSheet({super.key, required this.candidates});

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
            Text('Agregar miembro', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  'Todos los miembros del tenant ya pertenecen a este departamento.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  itemBuilder: (_, index) {
                    final member = candidates[index];
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
