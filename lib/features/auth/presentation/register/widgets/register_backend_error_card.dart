import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterBackendErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const RegisterBackendErrorCard({super.key, required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 2.0), child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error al procesar registro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF991B1B)),
            style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
    );
  }
}
