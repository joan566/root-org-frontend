import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class MetricsSummaryBlock extends StatelessWidget {
  final int totalOrganizations; // REAL: Cantidad de tenants del usuario
  final String activeRole;      // REAL: Rol actual (ej: "Admin", "Propietario", "Colaborador")
  final int activeModules;      // REAL: Módulos disponibles en la app

  const MetricsSummaryBlock({
    required this.totalOrganizations,
    required this.activeRole,
    required this.activeModules,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricItem(
          Icons.corporate_fare_rounded,
          '$totalOrganizations',
          'Organizaciones',
        ),
        _buildMetricItem(
          Icons.badge_outlined,
          activeRole,
          'Rol activo',
        ),
        _buildMetricItem(
          Icons.widgets_outlined,
          '$activeModules',
          'Módulos listos',
        ),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.translucentCardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }
}