import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'shell_section.dart';

const double _kExpandedWidth = 240;
const double _kCollapsedWidth = 76;

/// Los 4 módulos que se listan como submenú de "Módulos" (mismo set y mismo
/// color de identidad que las tarjetas del dashboard desktop, ver
/// `dashboard_general_desktop_view.dart`). Todos navegan hoy a la misma
/// `AppRoutes.modules` -- ningún módulo tiene ruta propia todavía.
const List<(IconData, String)> _kModuleSubitems = [
  (Icons.account_balance_wallet_outlined, 'Gestión Financiera'),
  (Icons.inventory_2_outlined, 'Inventario'),
  (Icons.event_note_outlined, 'Actividades'),
  (Icons.request_quote_outlined, 'Gestión de Préstamos'),
];

/// Navegación lateral del shell en Desktop (ver
/// docs/00-core/07-refactor-arquitectura-frontend/04-estrategia-responsive.md
/// y docs/frontend-navigation-redesign.md §2). Colapsable (solo iconos) y con
/// submenú expandible bajo "Módulos".
class ShellSidebar extends StatefulWidget {
  final List<ShellSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ShellSidebar({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<ShellSidebar> createState() => _ShellSidebarState();
}

class _ShellSidebarState extends State<ShellSidebar> {
  bool _collapsed = false;
  bool _modulesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: _collapsed ? _kCollapsedWidth : _kExpandedWidth,
      color: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                _collapsed ? AppSpacing.md : AppSpacing.xxl,
                AppSpacing.xxl,
                _collapsed ? AppSpacing.md : AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Row(
                mainAxisAlignment: _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: colors.slateDark, borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.blur_on_rounded, color: colors.primary, size: 18),
                  ),
                  if (!_collapsed) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'SUMKEYA',
                        style: AppTypography.titleSmall.copyWith(color: colors.textPrimary, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < widget.sections.length; i++) ...[
              _SidebarItem(
                section: widget.sections[i],
                selected: i == widget.selectedIndex,
                collapsed: _collapsed,
                onTap: () => widget.onSelect(i),
                trailing: (!_collapsed && widget.sections[i].route == AppRoutes.modules)
                    ? _ExpandChevron(
                        expanded: _modulesExpanded,
                        onTap: () => setState(() => _modulesExpanded = !_modulesExpanded),
                      )
                    : null,
              ),
              if (!_collapsed && widget.sections[i].route == AppRoutes.modules && _modulesExpanded)
                for (final (icon, label) in _kModuleSubitems)
                  _SidebarSubitem(icon: icon, label: label, onTap: () => widget.onSelect(i)),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: _CollapseToggle(
                collapsed: _collapsed,
                onTap: () => setState(() {
                  _collapsed = !_collapsed;
                  if (_collapsed) _modulesExpanded = false;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final ShellSection section;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final row = Row(
      mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (!collapsed) ...[
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Icon(section.icon, size: 20, color: selected ? colors.primary : colors.textSecondary),
        if (!collapsed) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              section.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? colors.primary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ],
    );

    final item = Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? AppSpacing.sm : AppSpacing.md, vertical: AppSpacing.xxs),
      child: Material(
        color: selected ? colors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? AppSpacing.sm : AppSpacing.lg, vertical: AppSpacing.md),
            child: row,
          ),
        ),
      ),
    );

    if (!collapsed) return item;
    return Tooltip(message: section.label, waitDuration: const Duration(milliseconds: 400), child: item);
  }
}

class _SidebarSubitem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarSubitem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 43, right: AppSpacing.lg, top: AppSpacing.sm, bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
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

class _ExpandChevron extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandChevron({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 150),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _CollapseToggle extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _CollapseToggle({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppPalette colors = AppColors.of(context);

    return Material(
      color: colors.background,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Icon(
            collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            size: 20,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
