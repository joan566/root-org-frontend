import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';


class UpcomingModulesSection extends StatelessWidget {
  const UpcomingModulesSection();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modules = [
      {'icon': '🏦', 'title': 'Finance Core', 'desc': 'Administra aportes, préstamos y flujos.', 'badge': 'Disponible', 'color': AppColors.success},
      {'icon': '👥', 'title': 'Human Resources', 'desc': 'Nóminas, contratos y onboarding.', 'badge': 'Muy pronto', 'color': AppColors.warning},
      {'icon': '📊', 'title': 'Advanced Analytics', 'desc': 'Visualiza indicadores financieros.', 'badge': 'Beta Pública', 'color': AppColors.borderFocus},
      {'icon': '📅', 'title': 'Smart Scheduling', 'desc': 'Calendarios y flujos automatizados.', 'badge': 'Próximamente', 'color': AppColors.textMuted},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text('Módulos del ecosistema global', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                decoration: AppColors.translucentCardDecoration(radius: 20), // Corregido[cite: 1]
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
                        Text(mod['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(mod['desc'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
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