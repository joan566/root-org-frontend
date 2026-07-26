import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';

class QuickMetricsBar extends StatelessWidget {
  final bool hasOrganizations;
  final String? activeOrganizationName; // NUEVO: Nombre real de la organización
  final double profileProgress;          // NUEVO: Porcentaje real (ej. 0.85 para 85%)
  final String lastAccessInfo;          // NUEVO: Ej. "Hoy, 10:42 AM • Windows"
  final VoidCallback onSimulationToggle;
  final VoidCallback? onCompleteProfile; // NUEVO: Acción para completar perfil
  final VoidCallback? onViewAccessDetails; // NUEVO: Acción para ver detalles de acceso

  const QuickMetricsBar({
    required this.hasOrganizations,
    this.activeOrganizationName,
    required this.profileProgress,
    required this.lastAccessInfo,
    required this.onSimulationToggle,
    this.onCompleteProfile,
    this.onViewAccessDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 12.0;
        double availableWidth = constraints.maxWidth - (spacing * 2);
        bool useVertical = constraints.maxWidth < 650;

        // Convertimos el valor decimal (ej: 0.85) a texto de porcentaje entero (ej: "85%")
        final int progressPercentage = (profileProgress * 100).toInt();

        List<Widget> cards = [
          _buildQuickCard(
            colors,
            width: useVertical ? double.infinity : availableWidth / 3,
            icon: Icons.corporate_fare_rounded,
            title: 'Organización activa',
            // Muestra el nombre real si existe, sino un fallback
            subtitle: hasOrganizations
                ? (activeOrganizationName ?? 'Cargando...')
                : 'Ninguna seleccionada',
            actionLabel: 'Simular cambio',
            onTap: onSimulationToggle,
            badgeIndicator: true,
            badgeColor: hasOrganizations ? colors.success : colors.warning,
          ),
          _buildQuickCard(
            colors,
            width: useVertical ? double.infinity : availableWidth / 3,
            icon: Icons.donut_large_rounded,
            title: 'Estado del perfil',
            subtitle: '$progressPercentage% completado',
            isProgress: true,
            progressValue: profileProgress,
            actionLabel: 'Completar',
            onTap: onCompleteProfile ?? () {},
          ),
          _buildQuickCard(
            colors,
            width: useVertical ? double.infinity : availableWidth / 3,
            icon: Icons.devices_rounded,
            title: 'Último acceso',
            subtitle: lastAccessInfo,
            actionLabel: 'Detalles',
            onTap: onViewAccessDetails ?? () {},
          ),
        ];

        return useVertical
            ? Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c)).toList())
            : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: cards);
      },
    );
  }

  Widget _buildQuickCard(
    AppPalette colors, {
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isProgress = false,
    double progressValue = 0.0,
    required String actionLabel,
    required VoidCallback onTap,
    bool badgeIndicator = false,
    Color badgeColor = Colors.transparent,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
        boxShadow: colors.subtleShadow(),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                if (!isProgress)
                  Row(
                    children: [
                      if (badgeIndicator)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                        ),
                      Expanded(
                        child: Text(
                            subtitle,
                            style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mostramos el porcentaje dinámico encima de la barra
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 5,
                          backgroundColor: colors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}