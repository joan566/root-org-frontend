import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_capabilities.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';
import 'package:savings_api_frontend/shared/widgets/user_detail_bottom_sheet.dart';

import 'widgets/assign_member_bottom_sheet.dart';
import 'widgets/member_row.dart';

/// Gestión de miembros del departamento -- movida de `UnitDetailScreen`
/// (Organización→Estructura, gobierno) al Workspace (trabajo operativo),
/// ver docs/01-features/organizacion.md §"Workspace". Solo recibe `unitId`;
/// lee la unidad en vivo de `OrganizationUnitsProvider` en vez de tomar un
/// snapshot por constructor, así que un parche aplicado desde cualquier otra
/// pantalla (incluida la de Organización) se refleja aquí sin recargar.
class DepartmentMembersScreen extends StatelessWidget {
  final int unitId;

  const DepartmentMembersScreen({super.key, required this.unitId});

  String? _token(BuildContext context) => context.read<AuthProvider>().session?.token;

  Future<void> _openAssignMember(BuildContext context, DepartmentSummary summary, int tenantId) async {
    final activeMemberIds = summary.unit.members.where((m) => m.isActive).map((m) => m.userId).toSet();
    final candidates = context.read<TenantUsersProvider>().membersFor(tenantId).where((u) => !activeMemberIds.contains(u.userId)).toList();

    final userId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignMemberBottomSheet(candidates: candidates),
    );
    if (userId == null || !context.mounted) return;

    final token = _token(context);
    if (token == null) return;
    try {
      final member = await OrganizationUnitInjection.organizationUnitMemberActionsController().assign(unitId, tenantId, userId, token);
      if (!context.mounted) return;
      final patched = summary.unit.copyWith(members: [...summary.unit.members, member]);
      context.read<OrganizationUnitsProvider>().applyUpdate(tenantId, DepartmentSummary(unit: patched));
    } catch (e) {
      _showError(context, e);
    }
  }

  Future<void> _removeMember(BuildContext context, DepartmentSummary summary, int tenantId, TenantMember member) async {
    final confirmed = await _confirm(
      context,
      title: '¿Remover del departamento?',
      content: '${member.fullName} dejará de pertenecer a este departamento.',
      confirmLabel: 'Remover',
    );
    if (confirmed != true || !context.mounted) return;

    final token = _token(context);
    if (token == null) return;
    try {
      await OrganizationUnitInjection.organizationUnitMemberActionsController().remove(unitId, tenantId, member.userId, token);
      if (!context.mounted) return;
      final patched = summary.unit.copyWith(
        members: summary.unit.members.where((m) => m.userId != member.userId).toList(),
      );
      context.read<OrganizationUnitsProvider>().applyUpdate(tenantId, DepartmentSummary(unit: patched));
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<bool?> _confirm(BuildContext context, {required String title, required String content, required String confirmLabel}) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(confirmLabel)),
        ],
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _viewProfile(BuildContext context, TenantMember member) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailBottomSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final activeTenant = activeUserTenant(context);
    final tenantId = activeTenant?.tenant.id;
    final currentUserId = context.read<AuthProvider>().session?.user.id;

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
        title: Text('Miembros', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: summary == null || tenantId == null || currentUserId == null
          ? Center(
              child: Text('No se encontró el departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
            )
          : _buildBody(context, colors, summary, tenantId, currentUserId),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppPalette colors,
    DepartmentSummary summary,
    int tenantId,
    int currentUserId,
  ) {
    final managerId = context.watch<OrganizationUnitsProvider>().managerFor(unitId)?.userId;
    final capabilities = DepartmentCapabilities(context.watch<PermissionsProvider>().codesForUnit(tenantId, unitId));
    final tenantUsersProvider = context.watch<TenantUsersProvider>();
    final usersById = {for (final u in tenantUsersProvider.membersFor(tenantId)) u.userId: u};
    final rows = summary.unit.members.map((m) => MapEntry(m, usersById[m.userId])).where((entry) => entry.value != null).toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (capabilities.canAssignMember)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openAssignMember(context, summary, tenantId),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Agregar miembro'),
              ),
            ),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text('Aún no hay miembros en este departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
                  )
                : ListView(
                    children: [
                      for (final entry in rows)
                        MemberRow(
                          member: entry.value!,
                          isActive: entry.key.isActive,
                          isManager: entry.key.userId == managerId,
                          canRemove: capabilities.canRemoveMember,
                          onViewProfile: () => _viewProfile(context, entry.value!),
                          onRemove: () => _removeMember(context, summary, tenantId, entry.value!),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
