import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'base_container_card.dart';
import 'data_tile.dart';

class ContactInfoCard extends StatelessWidget {
  final String email;
  final String phone;
  final VoidCallback onEdit;

  const ContactInfoCard({required this.email, required this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return BaseContainerCard(
      title: 'Información de contacto',
      icon: Icons.alternate_email_rounded,
      children: [
        DataTile(icon: Icons.mail_outline_rounded, label: 'Correo Electrónico', value: email),
        const Divider(color: AppColors.border, height: 1),
        DataTile(icon: Icons.phone_android_rounded, label: 'Teléfono Móvil', value: phone),
        const Divider(color: AppColors.border, height: 1),
        const DataTile(icon: Icons.map_outlined, label: 'Dirección Comercial', value: 'No configurada', isPlaceholder: true),
      ],
    );
  }
}