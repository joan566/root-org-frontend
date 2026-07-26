import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'base_container_card.dart';

class PreferencesCard extends StatelessWidget {
  const PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return BaseContainerCard(
      title: 'Preferencias del entorno',
      icon: Icons.tune_rounded,
      children: [
        _buildPreferenceRow('Tema visual del sistema', 'Claro / Light Mode', Icons.light_mode_rounded),
        const Divider(color: AppColors.border, height: 1),
        _buildPreferenceRow('Idioma de interfaz', 'Español (Latinoamérica)', Icons.language_rounded),
        const Divider(color: AppColors.border, height: 1),
        _buildPreferenceRow('Región y Zona Horaria', 'Bogotá, Colombia (GMT-5)', Icons.public_rounded),
      ],
    );
  }

  Widget _buildPreferenceRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_right_rounded, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}