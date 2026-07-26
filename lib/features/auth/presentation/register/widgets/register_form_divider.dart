import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterFormDivider extends StatelessWidget {
  const RegisterFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('o regístrate con', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}
