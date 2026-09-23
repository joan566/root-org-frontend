import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';

/// Crear o editar un departamento (`OrganizationUnit`). En modo crear
/// siempre se envía `parentUnitId: null` (unidad raíz) -- esta iteración no
/// expone jerarquía en la UI (ver plan de Estructura Organizacional). En
/// modo editar se preserva el `parentUnitId`/`status` originales de
/// [existing] para no tocarlos desde este formulario.
class CreateEditDepartmentBottomSheet extends StatefulWidget {
  final int tenantId;
  final OrganizationUnit? existing;

  const CreateEditDepartmentBottomSheet({super.key, required this.tenantId, this.existing});

  @override
  State<CreateEditDepartmentBottomSheet> createState() => _CreateEditDepartmentBottomSheetState();
}

class _CreateEditDepartmentBottomSheetState extends State<CreateEditDepartmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _loading = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
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
      final OrganizationUnit result;
      if (_isEditing) {
        result = await OrganizationUnitInjection.updateOrganizationUnitController().update(
          id: widget.existing!.id,
          tenantId: widget.tenantId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          parentUnitId: widget.existing!.parentUnitId,
          status: widget.existing!.status,
          token: token,
        );
      } else {
        result = await OrganizationUnitInjection.createOrganizationUnitController().create(
          tenantId: widget.tenantId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          token: token,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'No se pudo guardar el departamento.';
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
            Text(_isEditing ? 'Editar departamento' : 'Crear departamento', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
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
                labelText: 'Descripción (opcional)',
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
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear departamento', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
