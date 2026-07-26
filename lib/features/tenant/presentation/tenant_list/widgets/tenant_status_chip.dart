import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class TenantStatusChip extends StatelessWidget {
  final String status;
  const TenantStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppColors.textSecondary;
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    if (status.toLowerCase() == 'activo' || status.toLowerCase() == 'activa') {
      dotColor = AppColors.success;
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (status.toLowerCase() == 'pendiente') {
      dotColor = AppColors.warning;
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (status.toLowerCase() == 'suspendido') {
      dotColor = AppColors.error;
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
