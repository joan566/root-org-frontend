import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/shared/widgets/base_container_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BaseContainerCard(
      title: 'Actividad reciente de la cuenta',
      icon: Icons.history_toggle_off_rounded,
      children: [
        _buildActivityRow(colors, 'Ingreso autorizado al sistema corporativo', 'Hace 2 horas', Icons.login_rounded),
        Divider(color: colors.border, height: 1, indent: 45),
        _buildActivityRow(colors, 'Actualización de información de contacto (Teléfono)', 'Hace 5 días', Icons.phone_android_rounded),
        Divider(color: colors.border, height: 1, indent: 45),
        _buildActivityRow(colors, 'Cambio global de contraseña de seguridad', 'Hace 2 meses', Icons.lock_reset_rounded),
      ],
    );
  }

  Widget _buildActivityRow(AppPalette colors, String action, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}