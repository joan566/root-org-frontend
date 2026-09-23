import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Resumen rápido de la relación del usuario con los departamentos del
/// tenant activo, mismo layout que `StructureSummaryRow` (Admin) pero con
/// indicadores orientados a participación, no a administración.
class StructureMemberSummaryRow extends StatelessWidget {
  final int myDepartments;
  final int pendingRequests;
  final int availableDepartments;

  const StructureMemberSummaryRow({
    super.key,
    required this.myDepartments,
    required this.pendingRequests,
    required this.availableDepartments,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Wrap(
        spacing: AppSpacing.xxl,
        runSpacing: AppSpacing.md,
        children: [
          _StatColumn(value: '$myDepartments', label: 'Mis departamentos', colors: colors),
          _StatColumn(
            value: '$pendingRequests',
            label: pendingRequests == 1 ? 'Solicitud pendiente' : 'Solicitudes pendientes',
            colors: colors,
            valueColor: pendingRequests > 0 ? colors.warning : null,
          ),
          _StatColumn(value: '$availableDepartments', label: 'Departamentos disponibles', colors: colors),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette colors;
  final Color? valueColor;

  const _StatColumn({required this.value, required this.label, required this.colors, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: valueColor ?? colors.textPrimary)),
        Text(label, style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
