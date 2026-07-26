import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {'icon': Icons.login_rounded, 'title': 'Inicio de sesión', 'time': 'Hace 5 min', 'desc': 'Chrome • Windows', 'color': AppColors.success},
      {'icon': Icons.edit_outlined, 'title': 'Perfil actualizado', 'time': 'Ayer', 'desc': 'Número telefónico agregado', 'color': AppColors.borderFocus},
      {'icon': Icons.add_business_rounded, 'title': 'Organización creada', 'time': 'Hace 3 días', 'desc': 'Colegio San José', 'color': AppColors.primary},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.translucentCardDecoration(radius: 24), // Corregido[cite: 1]
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Actividad reciente', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('Ver todo', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final act = activities[index];
              final bool isLast = index == activities.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(act['icon'], size: 14, color: act['color']),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 34,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(act['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text(act['time'], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(act['desc'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }
}