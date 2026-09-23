import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

class StructureEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const StructureEmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle, boxShadow: colors.subtleShadow()),
            child: Icon(Icons.account_tree_outlined, size: 40, color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Aún no existen departamentos.',
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Crea el primero para comenzar a organizar tu organización.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear departamento'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            ),
          ),
        ],
      ),
    );
  }
}
