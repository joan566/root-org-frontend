import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';

import 'department_status_chip.dart';

/// Card de un departamento en la lista de Estructura. Icono y color no
/// existen en el backend (`OrganizationUnitInfo` no los trae) -- se derivan
/// determinísticamente del nombre, mismo patrón que `OrganizationCard` usa
/// para el avatar de organizaciones. No muestra el encargado (ADR-021 lo
/// movió a `GET /organization-units/{id}/manager`, ya no embebido -- pedirlo
/// para cada card de esta lista dispararía un GET por departamento; se ve en
/// el detalle de cada unidad).
class DepartmentCard extends StatelessWidget {
  final DepartmentSummary summary;
  final VoidCallback onTap;

  const DepartmentCard({super.key, required this.summary, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final unit = summary.unit;
    final brandColor = _colorFor(unit.name);
    final icon = _iconFor(unit.name);

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
                    DepartmentStatusChip(status: unit.status),
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
                    const Spacer(),
                    Text('Ver', style: AppTypography.labelLarge.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
