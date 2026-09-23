import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_injection.dart';

/// Formulario "Editar organización" (ver docs/01-features/organizacion.md).
/// Solo nombre/descripción -- `PUT /tenant/{id}` explícitamente no toca
/// código ni estado. Requiere `core.tenant.update` en el backend; quién ve
/// el botón que abre esto se decide en `OrganizationCapabilities`
/// (cosmético, ver ese archivo) desde `OrganizationScreen`.
class EditOrganizationBottomSheet extends StatefulWidget {
  final int tenantId;
  final String initialName;
  final String initialDescription;

  const EditOrganizationBottomSheet({
    super.key,
    required this.tenantId,
    required this.initialName,
    required this.initialDescription,
  });

  @override
  State<EditOrganizationBottomSheet> createState() => _EditOrganizationBottomSheetState();
}

class _EditOrganizationBottomSheetState extends State<EditOrganizationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await TenantInjection.updateTenantController().updateTenant(
        widget.tenantId,
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        token,
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'No se pudo actualizar la organización.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            Text('Editar organización', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'El código de invitación y el estado de la organización no se modifican desde aquí.',
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: AppTypography.labelSmall.copyWith(color: colors.error)),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
