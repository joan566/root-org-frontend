import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';

/// Vitrina de los módulos del mapa de navegación (ver
/// docs/frontend-navigation-redesign.md §3.2). Ninguno tiene backend
/// propio todavía, así que las 4 tarjetas muestran el mismo estado
/// honesto ("Próximamente") en vez de badges inventados — y las 4
/// llevan a la misma sección "Módulos" del shell (placeholder único),
/// no a rutas por módulo que todavía no existen (esas llegan en la
/// Fase 4).
class UpcomingModulesSection extends StatelessWidget {
  const UpcomingModulesSection();

  static const List<Map<String, String>> _modules = [
    {'icon': '💰', 'title': 'Gestión Financiera', 'desc': 'Movimientos, períodos, balances y reportes.'},
    {'icon': '🏦', 'title': 'Gestión de Préstamos', 'desc': 'Solicitudes, cuotas y seguimiento de cartera.'},
    {'icon': '📦', 'title': 'Inventario', 'desc': 'Productos registrados y alertas de stock.'},
    {'icon': '📋', 'title': 'Actividades', 'desc': 'Eventos y tareas de la organización.'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text('Módulos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final mod = _modules[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.modules),
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: colors.translucentCardDecoration(radius: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(mod['icon']!, style: const TextStyle(fontSize: 22)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colors.textMuted.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Próximamente',
                                style: TextStyle(color: colors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mod['title']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                            const SizedBox(height: 3),
                            Text(
                              mod['desc']!,
                              style: TextStyle(fontSize: 11, color: colors.textSecondary, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
