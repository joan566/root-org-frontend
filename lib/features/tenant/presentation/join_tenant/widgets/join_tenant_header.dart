import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class JoinTenantHeader extends StatelessWidget {
  const JoinTenantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: colors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.groups_rounded,
            size: 40,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Unirse a una organización",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.75,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Introduce el código proporcionado por tu fondo de ahorro para vincularte de forma inmediata y comenzar a colaborar.",
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
