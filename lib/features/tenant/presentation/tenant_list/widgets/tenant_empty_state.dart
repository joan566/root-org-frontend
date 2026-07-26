import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class TenantEmptyState extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onCreate;

  const TenantEmptyState({super.key, required this.onJoin, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle, boxShadow: colors.subtleShadow()),
            child: Icon(Icons.blur_on_rounded, size: 48, color: colors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Comienza tu ecosistema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Aún no perteneces a ninguna organización dentro de la plataforma SaaS. Crea un nuevo espacio de trabajo o únete a uno existente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear organización'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(220, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onJoin,
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: const Text('Unirse a una organización'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border, width: 1.5),
              minimumSize: const Size(220, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
