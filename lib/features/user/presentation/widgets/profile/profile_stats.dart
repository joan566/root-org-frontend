import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class ProfileStats extends StatelessWidget {
  final int tenantCount;

  const ProfileStats({super.key, required this.tenantCount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatItem(itemWidth, 'Organizaciones', tenantCount.toString(), Icons.corporate_fare_rounded),
            _buildStatItem(itemWidth, 'Seguridad 2FA', 'Inactivo', Icons.lock_outline_rounded, isAlert: true),
            _buildStatItem(itemWidth, 'Último Acceso', 'Hace 2 horas', Icons.devices_rounded),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(double width, String label, String value, IconData icon, {bool isAlert = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.subtleShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isAlert ? AppColors.warning : AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isAlert ? AppColors.warning : AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
