import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'interactive_action_button.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.corporate_fare_rounded, 'title': 'Mis organizaciones', 'route': AppRoutes.tenants},
      {'icon': Icons.person_outline_rounded, 'title': 'Editar perfil', 'route': AppRoutes.profile},
      {'icon': Icons.shield_outlined, 'title': 'Seguridad', 'route': AppRoutes.profile},
      {'icon': Icons.add_box_outlined, 'title': 'Crear organización', 'highlight': true, 'route': AppRoutes.createTenant},
      {'icon': Icons.qr_code_scanner_rounded, 'title': 'Unirse por código', 'route': AppRoutes.joinTenant},
      {'icon': Icons.tune_rounded, 'title': 'Configuración', 'route': AppRoutes.profile},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text('Acciones directas de control', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.of(context).textPrimary, letterSpacing: -0.2)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 100,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final act = actions[index];
            return InteractiveActionButton(
              icon: act['icon'],
              title: act['title'],
              isHighlight: act['highlight'] == true,
              onTap: () {
                HapticFeedback.lightImpact();
                final currentRouteName = ModalRoute.of(context)?.settings.name;

                if (currentRouteName == act['route']) {
                  return;
                }

                Navigator.of(context).pushNamedAndRemoveUntil(
                  act['route'],
                      (route) => route.isFirst,
                );
              }
            );
          },
        ),
      ],
    );
  }
}