import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class WorkspaceFormHeader extends StatelessWidget {
  const WorkspaceFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
              child: Icon(Icons.add_box_outlined, color: colors.primary, size: 22),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(30), border: Border.all(color: colors.border)),
              child: Text('Paso 1 de 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text('Configurar nueva organización', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Configura el perímetro operativo inicial de tu entorno de control.', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
  }
}
