import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'base_container_card.dart';
import 'data_tile.dart';

class PersonalInfoCard extends StatelessWidget {
  final String name;
  final String? lastName;
  final String? document;
  final String? dateOfBirth;
  final String? gender;
  final VoidCallback onEdit;

  const PersonalInfoCard({
    required this.name,
    required this.lastName,
    required this.document,
    required this.dateOfBirth,
    required this.gender,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BaseContainerCard(
      title: 'Información personal',
      icon: Icons.person_outline_rounded,
      children: [
        DataTile(icon: Icons.badge_outlined, label: 'Nombre Completo', value: '$name $lastName'),
        Divider(color: colors.border, height: 1),
        DataTile(icon: Icons.fingerprint_rounded, label: 'Documento / Identificación', value: document ?? "No  especificado"),
        Divider(color: colors.border, height: 1),
        DataTile(icon: Icons.cake_outlined, label: 'Fecha de nacimiento', value: dateOfBirth ?? 'No especificado', isPlaceholder: true),
        Divider(color: colors.border, height: 1),
        DataTile(icon: Icons.transgender_rounded, label: 'Género / Sexo', value: gender ?? "No especificado"),
      ],
    );
  }
}