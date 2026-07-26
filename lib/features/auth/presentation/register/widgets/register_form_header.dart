import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterFormHeader extends StatelessWidget {
  const RegisterFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
              child: Icon(Icons.domain_add_rounded, color: colors.primary, size: 24),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(30), border: Border.all(color: colors.border)),
              child: Text('Paso 1 de 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text('Crear una cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Comienza a administrar tus organizaciones de forma segura.', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }
}
