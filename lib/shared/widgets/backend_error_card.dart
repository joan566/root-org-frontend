import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

/// Tarjeta de error de backend reutilizada entre auth, register y
/// create_tenant. `title` y `borderOpacity` son parametrizables porque
/// cada pantalla usaba un texto/valor ligeramente distinto antes de
/// unificarse (ver ADR-012-plan-migracion.md, seccion de Fase 6) - los
/// valores por defecto preservan el comportamiento de auth (login,
/// forgot_password, reset_password, verification_code).
class BackendErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onClose;
  final double borderOpacity;

  const BackendErrorCard({
    super.key,
    this.title = 'Error de autenticación',
    required this.message,
    required this.onClose,
    this.borderOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(borderOpacity)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
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
