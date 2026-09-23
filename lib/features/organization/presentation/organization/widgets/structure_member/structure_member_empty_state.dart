import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

enum StructureMemberEmptyVariant { noDepartments, noMemberships, noRequests }

/// Estados vacíos de la pestaña Estructura Organizacional (Member), ver
/// docs/01-features/organizacion.md. A diferencia de `StructureEmptyState`
/// (Admin), ninguna variante ofrece una acción de creación -- un Member solo
/// explora/solicita, nunca crea departamentos.
class StructureMemberEmptyState extends StatelessWidget {
  final StructureMemberEmptyVariant variant;

  const StructureMemberEmptyState({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final (icon, title, description) = switch (variant) {
      StructureMemberEmptyVariant.noDepartments => (
          Icons.account_tree_outlined,
          'Sin departamentos',
          'Esta organización aún no ha creado departamentos.',
        ),
      StructureMemberEmptyVariant.noMemberships => (
          Icons.groups_outlined,
          'Todavía no perteneces a ningún departamento',
          'Explora los departamentos disponibles y solicita unirte a aquellos donde quieras participar.',
        ),
      StructureMemberEmptyVariant.noRequests => (
          Icons.pending_actions_outlined,
          'Sin solicitudes',
          'No tienes solicitudes de ingreso en este momento.',
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle, boxShadow: colors.subtleShadow()),
            child: Icon(icon, size: 40, color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, textAlign: TextAlign.center, style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(description, textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}
