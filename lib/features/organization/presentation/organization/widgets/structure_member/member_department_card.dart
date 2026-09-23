import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/member_unit_relation.dart';

import 'member_relation_status_chip.dart';

/// Card de un departamento en la vista Member de Estructura Organizacional.
/// Mismo chrome visual que `DepartmentCard` (Admin), pero muestra la
/// relación del usuario en vez del estado ACTIVE/INACTIVE de la unidad, y
/// termina en un botón de acción que cambia según esa relación. No muestra
/// el encargado (ADR-021 lo movió a `GET /organization-units/{id}/manager`,
/// ya no embebido -- pedirlo para cada card de esta lista dispararía un GET
/// por departamento; se ve en el detalle de cada unidad).
class MemberDepartmentCard extends StatelessWidget {
  final DepartmentSummary summary;
  final MemberUnitRelation relation;
  final VoidCallback onTap;
  final VoidCallback? onRequestJoin;
  final VoidCallback? onCancelRequest;
  final bool busy;

  const MemberDepartmentCard({
    super.key,
    required this.summary,
    required this.relation,
    required this.onTap,
    this.onRequestJoin,
    this.onCancelRequest,
    this.busy = false,
  });

  // Duplicado intencional de `DepartmentCard._icons`/`_colors` (privados a
  // esa clase) -- el mismo departamento debe verse con el mismo icono/color
  // en la vista Admin y en la Member.
  static const _icons = [
    Icons.groups_rounded,
    Icons.workspaces_rounded,
    Icons.account_tree_rounded,
    Icons.hub_rounded,
    Icons.category_rounded,
  ];

  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  IconData _iconFor(String name) => _icons[name.hashCode.abs() % _icons.length];

  Color _colorFor(String name) => _colors[name.hashCode.abs() % _colors.length];

  (String, VoidCallback?) _action() {
    switch (relation.status) {
      case MemberUnitRelationStatus.member:
        return ('Ver departamento', onTap);
      case MemberUnitRelationStatus.notMember:
        return ('Solicitar ingreso', onRequestJoin);
      case MemberUnitRelationStatus.pending:
        return ('Cancelar solicitud', onCancelRequest);
      case MemberUnitRelationStatus.rejected:
        return ('Solicitar nuevamente', onRequestJoin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final unit = summary.unit;
    final brandColor = _colorFor(unit.name);
    final icon = _iconFor(unit.name);
    final (actionLabel, actionHandler) = _action();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: colors.subtleShadow(),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primary.withOpacity(0.04),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: brandColor.withOpacity(0.1),
                      child: Icon(icon, color: brandColor, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.name,
                            style: AppTypography.titleSmall.copyWith(color: colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (unit.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              unit.description,
                              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    MemberRelationStatusChip(status: relation.status),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(color: colors.border, height: 1),
                ),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.memberCount} ${summary.memberCount == 1 ? 'miembro' : 'miembros'}',
                      style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: busy ? null : actionHandler,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: busy
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                          )
                        : Text(actionLabel, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
