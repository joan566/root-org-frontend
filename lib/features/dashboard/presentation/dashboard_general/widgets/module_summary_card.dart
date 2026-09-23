import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';

/// Tarjeta grande de módulo para el grid 2x2 del dashboard desktop. Ninguno
/// de los 4 módulos tiene backend propio todavía (ver
/// docs/frontend-navigation-redesign.md §3.2), así que se mantiene el mismo
/// estado honesto "Próximamente" que ya usaba `UpcomingModulesSection`, solo
/// restyleado a tarjeta grande en vez de carrusel horizontal.
class ModuleSummaryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  /// Color de identidad del módulo (ver `dashboard_general_desktop_view.dart`
  /// -- reutiliza tokens ya existentes de `AppPalette`, no colores nuevos).
  final Color accentColor;

  const ModuleSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  State<ModuleSummaryCard> createState() => _ModuleSummaryCardState();
}

class _ModuleSummaryCardState extends State<ModuleSummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: colors.flatCardDecoration().copyWith(
              boxShadow: _isHovered ? colors.premiumShadow() : colors.subtleShadow(),
            ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.modules),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 3, color: widget.accentColor),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.12),
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: Icon(widget.icon, color: widget.accentColor, size: 22),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.textMuted.withOpacity(0.1),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Text(
                              'Próximamente',
                              style: TextStyle(color: colors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(widget.title, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Text(
                            'Abrir módulo',
                            style: AppTypography.labelLarge.copyWith(
                              color: widget.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: widget.accentColor),
                        ],
                      ),
                    ],
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
