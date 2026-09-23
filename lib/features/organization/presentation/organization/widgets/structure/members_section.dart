import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Sección "Miembros" del detalle de departamento. Permite al Admin agregar
/// directamente un usuario del tenant como integrante, sin pasar por el
/// flujo de solicitudes de ingreso -- necesario para poder asignar un
/// encargado (`ManagerSection` exige al menos un miembro activo, RN-ORG-008)
/// en un departamento recién creado que todavía no tiene a nadie.
class MembersSection extends StatelessWidget {
  final int activeMemberCount;
  final VoidCallback onAssign;

  const MembersSection({super.key, required this.activeMemberCount, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Miembros', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          Text(
            activeMemberCount == 0
                ? 'Aún no hay miembros en este departamento.'
                : '$activeMemberCount ${activeMemberCount == 1 ? 'miembro activo' : 'miembros activos'}',
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAssign,
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Agregar miembro'),
            ),
          ),
        ],
      ),
    );
  }
}
