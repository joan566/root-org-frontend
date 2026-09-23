import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/member_unit_relation.dart';

/// Chip de la relación del usuario autenticado con un departamento --
/// distinto de `DepartmentStatusChip` (que muestra si la unidad en sí está
/// Activa/Inactiva). Modelado en `TenantStatusChip` (dot+pill multi-estado).
class MemberRelationStatusChip extends StatelessWidget {
  final MemberUnitRelationStatus status;

  const MemberRelationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    late final Color dotColor;
    late final Color bg;
    late final Color text;
    late final String label;

    switch (status) {
      case MemberUnitRelationStatus.member:
        dotColor = colors.success;
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        label = 'Miembro';
        break;
      case MemberUnitRelationStatus.pending:
        dotColor = colors.warning;
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        label = 'Solicitud pendiente';
        break;
      case MemberUnitRelationStatus.rejected:
        dotColor = colors.danger;
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = 'Solicitud rechazada';
        break;
      case MemberUnitRelationStatus.notMember:
        dotColor = colors.textMuted;
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
        label = 'No perteneces';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
