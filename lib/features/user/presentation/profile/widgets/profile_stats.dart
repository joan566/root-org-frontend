import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

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
            _buildStatItem(context, itemWidth, 'Organizaciones', tenantCount.toString(), Icons.corporate_fare_rounded),
            _buildStatItem(context, itemWidth, 'Seguridad 2FA', 'Inactivo', Icons.lock_outline_rounded, isAlert: true),
            _buildStatItem(context, itemWidth, 'Último Acceso', 'Hace 2 horas', Icons.devices_rounded),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, double width, String label, String value, IconData icon, {bool isAlert = false}) {
    final colors = AppColors.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: colors.subtleShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isAlert ? colors.warning : colors.textSecondary),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isAlert ? colors.warning : colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
