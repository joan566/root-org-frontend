import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

/// Información de solo lectura del departamento dentro del Workspace --
/// nunca edita nada (editar/activar/desactivar/eliminar sigue siendo
/// exclusivo de Organización→Estructura, ver docs/01-features/organizacion.md
/// §"Workspace").
class DepartmentInfoScreen extends StatelessWidget {
  final int unitId;

  const DepartmentInfoScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenantId = activeUserTenant(context)?.tenant.id;
    final summaries = tenantId == null ? const <DepartmentSummary>[] : context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    DepartmentSummary? summary;
    for (final s in summaries) {
      if (s.unit.id == unitId) {
        summary = s;
        break;
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Información', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: summary == null
          ? Center(
              child: Text('No se encontró el departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
            )
          : _buildBody(context, colors, summary, tenantId!),
    );
  }

  Widget _buildBody(BuildContext context, AppPalette colors, DepartmentSummary summary, int tenantId) {
    final unit = summary.unit;
    final manager = context.watch<OrganizationUnitsProvider>().managerFor(unitId);
    final managerProfile = manager == null ? null : context.watch<TenantUsersProvider>().findById(tenantId, manager.userId);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: colors.flatCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unit.name, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                unit.description.isEmpty ? 'Sin descripción registrada' : unit.description,
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoLine(label: 'Estado', value: unit.isActive ? 'Activo' : 'Inactivo', colors: colors),
              _InfoLine(
                label: 'Miembros activos',
                value: '${unit.members.where((m) => m.isActive).length}',
                colors: colors,
              ),
              _InfoLine(
                label: 'Creado el',
                value: '${unit.createdAt.day.toString().padLeft(2, '0')}/${unit.createdAt.month.toString().padLeft(2, '0')}/${unit.createdAt.year}',
                colors: colors,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: colors.flatCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Encargado', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              if (managerProfile == null)
                Text('Sin encargado asignado', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary))
              else
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.primaryLight,
                      child: Text(
                        managerProfile.name.isEmpty ? '?' : managerProfile.name[0].toUpperCase(),
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(managerProfile.fullName, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final AppPalette colors;

  const _InfoLine({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary))),
          Expanded(child: Text(value, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
