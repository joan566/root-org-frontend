import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

/// Label de campo de formulario reutilizado entre auth y tenant.
/// `fontWeight` es parametrizable porque create_tenant usaba w700 en vez
/// del w600 de auth antes de unificarse (ver ADR-012-plan-migracion.md,
/// seccion de Fase 6). El valor por defecto preserva el de auth.
class FieldLabel extends StatelessWidget {
  final String label;
  final FontWeight fontWeight;

  const FieldLabel({
    super.key,
    required this.label,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: fontWeight, color: AppColors.textPrimary),
    );
  }
}
