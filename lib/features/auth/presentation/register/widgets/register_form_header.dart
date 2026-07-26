import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterFormHeader extends StatelessWidget {
  const RegisterFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.domain_add_rounded, color: AppColors.primary, size: 24),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border)),
              child: const Text('Paso 1 de 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text('Crear una cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Comienza a administrar tus organizaciones de forma segura.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
