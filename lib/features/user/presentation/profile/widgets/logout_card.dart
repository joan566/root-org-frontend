import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: colors.subtleShadow(),
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
                      decoration: BoxDecoration(color: colors.danger.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(Icons.logout_rounded, color: colors.danger, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cerrar sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.danger)),
                          const SizedBox(height: 2),
                          Text('Se finalizará el token de sesión en este terminal.', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
            Divider(color: colors.border, height: 1),
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
                      decoration: BoxDecoration(color: colors.textSecondary.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(Icons.delete_forever_rounded, color: colors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solicitar eliminación de cuenta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Inicia el protocolo legal de borrado de datos (GDPR/ARCO).', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
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