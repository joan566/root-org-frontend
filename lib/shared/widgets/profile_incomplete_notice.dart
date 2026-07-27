import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Aviso reutilizable para cuando una acción requiere perfil personal
/// completo (`User.isProfileComplete`) y el usuario todavía no lo tiene.
/// Se usa en 3 lugares: el gate de selección de organización tras el login
/// (`SelectTenantScreen`), `CreateTenantScreen` y `JoinTenantScreen` — por
/// eso vive en `shared/`, no en una sola feature.
class ProfileIncompleteNotice extends StatelessWidget {
  final VoidCallback onCompleteProfile;
  final String title;
  final String message;

  const ProfileIncompleteNotice({
    super.key,
    required this.onCompleteProfile,
    this.title = 'Completa tu perfil para continuar',
    this.message =
        'Antes de crear o unirte a una organización, necesitamos que completes algunos datos básicos de tu perfil: nombre, apellido, documento, teléfono, fecha de nacimiento y género.',
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: colors.primaryLight, shape: BoxShape.circle),
              child: Icon(Icons.assignment_ind_outlined, size: 40, color: colors.primary),
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
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary, height: 1.4),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCompleteProfile,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Completar mi perfil'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
