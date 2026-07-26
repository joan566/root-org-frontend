import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class PasswordHeader extends StatelessWidget {
  final bool isDesktop;
  const PasswordHeader({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final double iconSize = isDesktop ? 72 : 56;

    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: colors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            color: colors.primary,
            size: iconSize * 0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Cambiar contraseña",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            "Actualiza tu contraseña para mantener tu cuenta protegida. Asegúrate de utilizar una contraseña segura y fácil de recordar.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
