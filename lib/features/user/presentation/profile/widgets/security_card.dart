import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/routing/app_navigator.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'base_container_card.dart';
import 'data_tile.dart';

class SecurityCard extends StatelessWidget {
  const SecurityCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BaseContainerCard(
      title: 'Seguridad y autenticación',
      icon: Icons.shield_outlined,
      children: [
        const DataTile(icon: Icons.password_rounded, label: 'Contraseña del sistema', value: '••••••••••••'),
        Divider(color: colors.border, height: 1),
        const DataTile(icon: Icons.phonelink_lock_rounded, label: 'Verificación en dos pasos (2FA)', value: 'Desactivado', isPlaceholder: true),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    AppNavigator.push(context, AppRoutes.changePassword);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: colors.border),
                  ),
                  child: Text('Cambiar contraseña', style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: colors.border),
                  ),
                  child: Text('Cerrar otras sesiones', style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}