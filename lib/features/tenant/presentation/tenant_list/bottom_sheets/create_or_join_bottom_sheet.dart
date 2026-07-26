import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

void showCreateOrJoinBottomSheet(
  BuildContext context, {
  required VoidCallback onCreate,
  required VoidCallback onJoin,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 24),
              const Text('Configura tu espacio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4)),
              const SizedBox(height: 4),
              const Text('Elige el método de aprovisionamiento de tu espacio.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _buildOption(context, Icons.business_rounded, AppColors.primary, 'Crear nueva organización', 'Configura la estructura para un nuevo entorno corporativo.', onCreate),
              const SizedBox(height: 12),
              _buildOption(context, Icons.vpn_key_outlined, const Color(0xFF3B82F6), 'Unirse mediante invitación', 'Introduce un token válido otorgado por tu administrador.', onJoin),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildOption(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback action) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
      action();
    },
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
        ],
      ),
    ),
  );
}
