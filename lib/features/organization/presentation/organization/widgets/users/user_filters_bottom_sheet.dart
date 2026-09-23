import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

enum UserStatusFilter { all, active }

enum UserSortMode {
  nameAsc('Nombre A-Z', enabled: true),
  nameDesc('Nombre Z-A', enabled: true),
  mostRecent('Más recientes', enabled: false),
  oldest('Más antiguos', enabled: false),
  lastAccess('Último acceso', enabled: false);

  final String label;
  final bool enabled;

  const UserSortMode(this.label, {required this.enabled});
}

class UserFiltersResult {
  final UserStatusFilter status;
  final Set<String> roles;
  final UserSortMode sort;

  const UserFiltersResult({required this.status, required this.roles, required this.sort});
}

/// Bottom sheet de filtros/orden de la pestaña Usuarios (ver
/// docs/01-features/organizacion.md). "Más recientes"/"Más antiguos"/
/// "Último acceso" se muestran pero deshabilitados: no hay ningún campo de
/// fecha en `GET /tenant/{id}/users` con el que ordenar por eso.
class UserFiltersBottomSheet extends StatefulWidget {
  final UserStatusFilter initialStatus;
  final Set<String> initialRoles;
  final UserSortMode initialSort;
  final Set<String> availableRoles;

  const UserFiltersBottomSheet({
    super.key,
    required this.initialStatus,
    required this.initialRoles,
    required this.initialSort,
    required this.availableRoles,
  });

  @override
  State<UserFiltersBottomSheet> createState() => _UserFiltersBottomSheetState();
}

class _UserFiltersBottomSheetState extends State<UserFiltersBottomSheet> {
  late UserStatusFilter _status = widget.initialStatus;
  late Set<String> _roles = {...widget.initialRoles};
  late UserSortMode _sort = widget.initialSort;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Filtrar y ordenar', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.xxl),

            Text('Estado', style: AppTypography.labelLarge.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _Chip(label: 'Todos', selected: _status == UserStatusFilter.all, colors: colors, onTap: () => setState(() => _status = UserStatusFilter.all)),
                _Chip(label: 'Activos', selected: _status == UserStatusFilter.active, colors: colors, onTap: () => setState(() => _status = UserStatusFilter.active)),
              ],
            ),

            if (widget.availableRoles.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Roles', style: AppTypography.labelLarge.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final role in widget.availableRoles)
                    _Chip(
                      label: role,
                      selected: _roles.contains(role),
                      colors: colors,
                      onTap: () => setState(() => _roles.contains(role) ? _roles.remove(role) : _roles.add(role)),
                    ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            Text('Ordenar por', style: AppTypography.labelLarge.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            for (final mode in UserSortMode.values)
              RadioListTile<UserSortMode>(
                value: mode,
                groupValue: _sort,
                onChanged: mode.enabled ? (v) => setState(() => _sort = v!) : null,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: colors.primary,
                title: Text(
                  mode.enabled ? mode.label : '${mode.label} (sin datos aún)',
                  style: AppTypography.bodyMedium.copyWith(color: mode.enabled ? colors.textPrimary : colors.textMuted),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  UserFiltersResult(status: _status, roles: _roles, sort: _sort),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
                child: const Text('Aplicar filtros', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final AppPalette colors;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withOpacity(0.12) : colors.background,
          borderRadius: AppRadius.borderPill,
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: selected ? colors.primary : colors.textSecondary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
