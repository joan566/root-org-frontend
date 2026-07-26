import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterFormDivider extends StatelessWidget {
  const RegisterFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('o regístrate con', style: TextStyle(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Expanded(child: Divider(color: colors.border, height: 1)),
      ],
    );
  }
}
