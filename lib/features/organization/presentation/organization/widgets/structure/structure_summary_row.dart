import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Resumen rápido de la estructura (sin gráficas, solo indicadores) --
/// departamentos totales y miembros distribuidos. Los conteos se calculan
/// sobre la lista ya cargada por `StructureTab`; el backend no expone un
/// endpoint de resumen. No incluye "sin encargado": ADR-021 movió el
/// encargado a `GET /organization-units/{id}/manager` (ya no viene embebido
/// en la lista), y calcularlo para todos los departamentos del tenant de una
/// sola vez dispararía un GET por unidad -- se ve por unidad, en su detalle.
class StructureSummaryRow extends StatelessWidget {
  final int totalDepartments;
  final int totalMembers;

  const StructureSummaryRow({
    super.key,
    required this.totalDepartments,
    required this.totalMembers,
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
          _StatColumn(value: '$totalDepartments', label: totalDepartments == 1 ? 'Departamento' : 'Departamentos', colors: colors),
          _StatColumn(value: '$totalMembers', label: totalMembers == 1 ? 'Miembro' : 'Miembros', colors: colors),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette colors;

  const _StatColumn({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
        Text(label, style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}
