import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿CÓMO FUNCIONA?',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 18),
        _buildStep(colors, '1', 'Solicita el código al administrador.'),
        _buildStep(colors, '2', 'Ingresa el código en esta pantalla.'),
        _buildStep(colors, '3', 'Comienza a trabajar dentro de la organización.', isLast: true),
      ],
    );
  }

  Widget _buildStep(AppPalette colors, String stepNum, String text, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
                child: Center(
                  child: Text(stepNum, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: colors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 16.0),
            child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSecondary)),
          )
        ],
      ),
    );
  }
}
