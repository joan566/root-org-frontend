import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_capabilities.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/roles_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

import 'widgets/assign_role_bottom_sheet.dart';
import 'widgets/role_member_row.dart';

/// Rol departamental por miembro (`POST`/`DELETE .../members/{userId}/role`,
/// endpoints 7/8 de `/organization-units`) -- sin UI en ningún lado antes de
/// este Workspace. Mismo criterio de lectura en vivo que
/// `DepartmentMembersScreen`: solo recibe `unitId`.
class DepartmentRolesScreen extends StatefulWidget {
  final int unitId;

  const DepartmentRolesScreen({super.key, required this.unitId});

  @override
  State<DepartmentRolesScreen> createState() => _DepartmentRolesScreenState();
}

class _DepartmentRolesScreenState extends State<DepartmentRolesScreen> {
  bool _rolesLoading = false;

  String? _token() => context.read<AuthProvider>().session?.token;

  Future<void> _ensureRolesLoaded(int tenantId) async {
    final rolesProvider = context.read<RolesProvider>();
    if (rolesProvider.isLoaded(tenantId)) return;
    final token = _token();
    if (token == null) return;

    setState(() => _rolesLoading = true);
    try {
      await rolesProvider.load(tenantId, token);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _rolesLoading = false);
    }
  }

  Future<void> _openAssign(DepartmentSummary summary, int tenantId, OrganizationUnitMember member) async {
    await _ensureRolesLoaded(tenantId);
    if (!mounted) return;

    // ADR-021: el rol ya no tiene un alcance fijo grabado en la fila --
    // cualquier rol del tenant es asignable a nivel de unidad, el alcance lo
    // determina la asignación, no el rol. Ya no se filtra por `scope`.
    final tenantRoles = context.read<RolesProvider>().rolesFor(tenantId);

    final role = await showModalBottomSheet<Role>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignRoleBottomSheet(roles: tenantRoles),
    );
    if (role == null || !mounted) return;

    final token = _token();
    if (token == null) return;
    try {
      await OrganizationUnitInjection.organizationUnitMemberActionsController().assignRole(widget.unitId, tenantId, member.userId, role.id, token);
      if (!mounted) return;
      _applyPatch(summary, tenantId, member.userId, (m) => m.copyWith(roleId: role.id, roleName: role.name));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _removeRole(DepartmentSummary summary, int tenantId, OrganizationUnitMember member) async {
    final roleId = member.roleId;
    if (roleId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Quitar rol departamental?'),
        content: Text('Se quitará el rol "${member.roleName}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Quitar')),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = _token();
    if (token == null) return;
    try {
      await OrganizationUnitInjection.organizationUnitMemberActionsController().removeRole(widget.unitId, tenantId, member.userId, roleId, token);
      if (!mounted) return;
      _applyPatch(summary, tenantId, member.userId, (m) => m.copyWith(roleId: null, roleName: null));
    } catch (e) {
      _showError(e);
    }
  }

  void _applyPatch(
    DepartmentSummary summary,
    int tenantId,
    int userId,
    OrganizationUnitMember Function(OrganizationUnitMember) patch,
  ) {
    final patchedMembers = summary.unit.members.map((m) => m.userId == userId ? patch(m) : m).toList();
    final patchedUnit = summary.unit.copyWith(members: patchedMembers);
    context.read<OrganizationUnitsProvider>().applyUpdate(tenantId, DepartmentSummary(unit: patchedUnit));
  }

  void _showError(Object e) {
    final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      if (s.unit.id == widget.unitId) {
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
        title: Text('Roles departamentales', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: summary == null || tenantId == null || currentUserId == null
          ? Center(
              child: Text('No se encontró el departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
            )
          : _buildBody(colors, summary, tenantId, currentUserId),
    );
  }

  Widget _buildBody(AppPalette colors, DepartmentSummary summary, int tenantId, int currentUserId) {
    final capabilities = DepartmentCapabilities(context.watch<PermissionsProvider>().codesForUnit(tenantId, widget.unitId));
    final usersById = {for (final u in context.watch<TenantUsersProvider>().membersFor(tenantId)) u.userId: u};
    final activeMembers = summary.unit.members.where((m) => m.isActive).toList();

    if (_rolesLoading) return const Center(child: CircularProgressIndicator());

    if (activeMembers.isEmpty) {
      return Center(
        child: Text('Aún no hay miembros activos en este departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        for (final member in activeMembers)
          if (usersById[member.userId] case final TenantMember profile)
            RoleMemberRow(
              member: profile,
              roleName: member.roleName,
              canManage: (member.roleName?.isNotEmpty ?? false) ? capabilities.canRemoveManager : capabilities.canAssignManager,
              onAssign: () => _openAssign(summary, tenantId, member),
              onRemove: () => _removeRole(summary, tenantId, member),
            ),
      ],
    );
  }
}
