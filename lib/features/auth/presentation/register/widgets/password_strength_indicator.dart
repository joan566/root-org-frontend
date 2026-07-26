import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    int points = 0;
    if (password.length >= 8) points++;
    if (password.contains(RegExp(r'[A-Z]'))) points++;
    if (password.contains(RegExp(r'[0-9]'))) points++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) points++;

    Color color = AppColors.error;
    String label = 'Fuerte debilidad';
    if (points == 2) { color = Colors.orange; label = 'Aceptable'; }
    if (points == 3) { color = Colors.amber; label = 'Media-Alta'; }
    if (points == 4) { color = AppColors.primary; label = 'Altamente Segura'; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < points ? color : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        Text('Seguridad local: $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
