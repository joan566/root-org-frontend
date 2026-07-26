import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class SuccessConfirmationView extends StatelessWidget {
  final VoidCallback onActionPressed;
  const SuccessConfirmationView({super.key, required this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
              boxShadow: colors.premiumShadow(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text('¡Registro exitoso!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(
                  'Tu cuenta ha sido creada correctamente en el ecosistema corporativo. Ahora puedes iniciar sesión con tus credenciales asignadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onActionPressed,
                    style: FilledButton.styleFrom(backgroundColor: colors.textPrimary, foregroundColor: colors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Ir al inicio de sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
