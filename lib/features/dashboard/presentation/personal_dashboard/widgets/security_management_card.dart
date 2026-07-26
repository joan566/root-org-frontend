import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';

class SecurityManagementCard extends StatelessWidget {
  const SecurityManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: colors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seguridad y accesos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 14),
          _buildSecurityRow(colors, 'Contraseña', 'Cambiada hace 2 meses'),
          _buildSecurityRow(colors, 'Sesiones activas', '2 terminales autorizadas'),
          _buildSecurityRow(colors, 'Verificación 2FA', 'Protección por app inactiva', isAlert: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Administrar seguridad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecurityRow(AppPalette colors, String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          const SizedBox(height: 1),
          Text(value, style: TextStyle(fontSize: 11, color: isAlert ? colors.warning : colors.textSecondary)),
        ],
      ),
    );
  }
}
