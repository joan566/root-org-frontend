import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.subtleShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            InkWell(
              onTap: onLogout,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), shape: BoxShape.circle),
                      child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cerrar sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.danger)),
                          SizedBox(height: 2),
                          Text('Se finalizará el token de sesión en este terminal.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                // Preparado estructuralmente para acciones destructivas futuras
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.08), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_forever_rounded, color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solicitar eliminación de cuenta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text('Inicia el protocolo legal de borrado de datos (GDPR/ARCO).', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}