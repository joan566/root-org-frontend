import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class SecurityManagementCard extends StatelessWidget {
  const SecurityManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seguridad y accesos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _buildSecurityRow('Contraseña', 'Cambiada hace 2 meses'),
          _buildSecurityRow('Sesiones activas', '2 terminales autorizadas'),
          _buildSecurityRow('Verificación 2FA', 'Protección por app inactiva', isAlert: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Administrar seguridad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecurityRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 1),
          Text(value, style: TextStyle(fontSize: 11, color: isAlert ? AppColors.warning : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
