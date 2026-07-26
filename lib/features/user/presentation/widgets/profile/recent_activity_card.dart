import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';
import 'base_container_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return BaseContainerCard(
      title: 'Actividad reciente de la cuenta',
      icon: Icons.history_toggle_off_rounded,
      children: [
        _buildActivityRow('Ingreso autorizado al sistema corporativo', 'Hace 2 horas', Icons.login_rounded),
        const Divider(color: AppColors.border, height: 1, indent: 45),
        _buildActivityRow('Actualización de información de contacto (Teléfono)', 'Hace 5 días', Icons.phone_android_rounded),
        const Divider(color: AppColors.border, height: 1, indent: 45),
        _buildActivityRow('Cambio global de contraseña de seguridad', 'Hace 2 meses', Icons.lock_reset_rounded),
      ],
    );
  }

  Widget _buildActivityRow(String action, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}