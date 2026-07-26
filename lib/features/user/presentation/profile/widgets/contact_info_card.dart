import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/shared/widgets/base_container_card.dart';
import 'data_tile.dart';

class ContactInfoCard extends StatelessWidget {
  final String email;
  final String phone;
  final VoidCallback onEdit;

  const ContactInfoCard({required this.email, required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BaseContainerCard(
      title: 'Información de contacto',
      icon: Icons.alternate_email_rounded,
      children: [
        DataTile(icon: Icons.mail_outline_rounded, label: 'Correo Electrónico', value: email),
        Divider(color: colors.border, height: 1),
        DataTile(icon: Icons.phone_android_rounded, label: 'Teléfono Móvil', value: phone),
        Divider(color: colors.border, height: 1),
        const DataTile(icon: Icons.map_outlined, label: 'Dirección Comercial', value: 'No configurada', isPlaceholder: true),
      ],
    );
  }
}