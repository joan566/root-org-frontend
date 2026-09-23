import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';

/// Formulario "Invitar usuario" (ver docs/01-features/organizacion.md). No
/// existe endpoint de invitación por correo todavía -- el formulario es
/// real, pero enviar termina en un aviso honesto de "Próximamente" en vez
/// de simular un envío exitoso (nunca un no-op silencioso).
class InviteUserBottomSheet extends StatefulWidget {
  const InviteUserBottomSheet({super.key});

  @override
  State<InviteUserBottomSheet> createState() => _InviteUserBottomSheetState();
}

class _InviteUserBottomSheetState extends State<InviteUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitar por correo estará disponible próximamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl),
      decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Invitar usuario', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Enviaremos una invitación a este correo para unirse a la organización.',
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Ingresa un correo';
                if (!value.contains('@')) return 'Ingresa un correo válido';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mensaje (opcional)',
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _send,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
                child: const Text('Enviar invitación', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
