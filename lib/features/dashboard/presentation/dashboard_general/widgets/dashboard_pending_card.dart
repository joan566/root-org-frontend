import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// "Pendientes importantes" del dashboard desktop. No existe todavía un
/// backend de solicitudes/alertas por organización (ver
/// docs/01-features/panel-principal.md), así que se muestra un estado vacío
/// honesto en vez de contadores inventados -- queda lista para poblarse
/// cuando exista ese backend.
class DashboardPendingCard extends StatelessWidget {
  const DashboardPendingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pendientes importantes', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.success.withOpacity(0.1), borderRadius: AppRadius.borderPill),
                    child: Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 24),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No hay pendientes por ahora',
                    style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Las solicitudes y alertas de tu organización aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
