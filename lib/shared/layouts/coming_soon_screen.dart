import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Placeholder honesto para secciones del nav sin backend/dominio todavía
/// (ver docs/frontend-navigation-redesign.md §3). Explica qué falta en vez
/// de mostrar una pantalla vacía sin contexto.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: ComingSoonView(title: title, description: description, icon: icon),
    );
  }
}

/// Mismo contenido que [ComingSoonScreen], sin `Scaffold` propio — para
/// embeber dentro de una pestaña o sección que ya tiene su propio Scaffold
/// (ej. una de las pestañas de `OrganizationScreen`).
class ComingSoonView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ComingSoonView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: colors.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: AppRadius.borderPill,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                'Próximamente',
                style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
