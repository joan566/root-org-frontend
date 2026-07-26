import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';


class UpcomingModulesSection extends StatelessWidget {
  const UpcomingModulesSection();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final List<Map<String, dynamic>> modules = [
      {'icon': '🏦', 'title': 'Finance Core', 'desc': 'Administra aportes, préstamos y flujos.', 'badge': 'Disponible', 'color': colors.success},
      {'icon': '👥', 'title': 'Human Resources', 'desc': 'Nóminas, contratos y onboarding.', 'badge': 'Muy pronto', 'color': colors.warning},
      {'icon': '📊', 'title': 'Advanced Analytics', 'desc': 'Visualiza indicadores financieros.', 'badge': 'Beta Pública', 'color': colors.borderFocus},
      {'icon': '📅', 'title': 'Smart Scheduling', 'desc': 'Calendarios y flujos automatizados.', 'badge': 'Próximamente', 'color': colors.textMuted},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text('Módulos del ecosistema global', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final mod = modules[index];
              return Container(
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
                        Text(mod['icon'], style: const TextStyle(fontSize: 22)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (mod['color'] as Color).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(mod['badge'], style: TextStyle(color: mod['color'], fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mod['title'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(mod['desc'], style: TextStyle(fontSize: 11, color: colors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}