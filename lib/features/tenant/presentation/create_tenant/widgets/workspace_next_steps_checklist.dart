import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class WorkspaceNextStepsChecklist extends StatelessWidget {
  const WorkspaceNextStepsChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('HOJA DE RUTA OPERATIVA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _buildCheckItem(true, 'Organización aprovisionada en base de datos central.'),
        _buildCheckItem(false, 'Completar parametrización y configuración regional.'),
        _buildCheckItem(false, 'Invitar miembros de confianza vía código hash.'),
        _buildCheckItem(false, 'Encender módulos funcionales y pasarelas de control.'),
      ],
    );
  }

  Widget _buildCheckItem(bool checked, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: checked ? AppColors.primary : AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: checked ? FontWeight.bold : FontWeight.normal, color: checked ? AppColors.textPrimary : AppColors.textSecondary))),
        ],
      ),
    );
  }
}
