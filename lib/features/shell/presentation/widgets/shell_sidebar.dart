import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'shell_section.dart';

/// Navegación lateral del shell en Desktop (ver
/// docs/00-core/07-refactor-arquitectura-frontend/04-estrategia-responsive.md
/// y docs/frontend-navigation-redesign.md §2).
class ShellSidebar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: 260,
      color: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: colors.slateDark, borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.blur_on_rounded, color: colors.primary, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'SUMKEYA',
                    style: AppTypography.titleSmall.copyWith(color: colors.textPrimary, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < sections.length; i++)
              _SidebarItem(
                section: sections[i],
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
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
  final VoidCallback onTap;

  const _SidebarItem({required this.section, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
      child: Material(
        color: selected ? colors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(section.icon, size: 20, color: selected ? colors.primary : colors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  section.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: selected ? colors.primary : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
