import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class FutureOrganizationTypeSelector extends StatelessWidget {
  const FutureOrganizationTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          Icon(Icons.layers_clear_outlined, size: 18, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text('Seleccionar sector (Empresa, Educación, Fundación)', style: TextStyle(fontSize: 13, color: colors.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4)),
            child: Text('Próximamente', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: colors.textSecondary)),
          )
        ],
      ),
    );
  }
}
