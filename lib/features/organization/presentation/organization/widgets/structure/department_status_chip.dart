import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class DepartmentStatusChip extends StatelessWidget {
  final String status;

  const DepartmentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isActive = status.toUpperCase() == 'ACTIVE';

    final dotColor = isActive ? colors.success : colors.textMuted;
    final bg = isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final text = isActive ? const Color(0xFF15803D) : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(isActive ? 'Activo' : 'Inactivo', style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
