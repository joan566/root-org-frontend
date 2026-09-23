import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/roles_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';

import '../../../../../organization_unit/presentation/workspace/members/widgets/assign_member_bottom_sheet.dart';
import '../../../../../organization_unit/presentation/workspace/roles/widgets/assign_role_bottom_sheet.dart';
import 'assign_manager_bottom_sheet.dart';
import 'create_edit_department_bottom_sheet.dart';
import 'manager_section.dart';
import 'members_section.dart';

/// Detalle de un departamento (`OrganizationUnit`) -- gobierno estructural
/// (Organización→Estructura, exclusivo de Admin): editar/activar/desactivar
/// /eliminar la unidad, agregar miembros y asignar/remover/transferir su
/// encargado. Agregar miembro está disponible tanto aquí (bootstrap: el
/// Admin puede poblar un departamento sin necesitar ser miembro de él) como
/// en el Workspace del departamento (`organization_unit/presentation/
/// workspace/`, ver docs/01-features/organizacion.md §"Workspace") -- ambos
/// llaman al mismo `assign()`. Remover miembros, roles departamentales, y la
/// bandeja de solicitudes de ingreso siguen siendo exclusivos del Workspace,
/// trabajo operativo del encargado, no gobierno.
///
/// Solo recibe `unitId`: lee la unidad en vivo de `OrganizationUnitsProvider`
/// (mismo cache que ya usa `StructureTab`) en vez de un snapshot por
/// constructor, así que un parche aplicado desde el Workspace (ej. aprobar
/// una solicitud de ingreso) se refleja aquí sin recargar.
class UnitDetailScreen extends StatefulWidget {
  final int unitId;

  const UnitDetailScreen({super.key, required this.unitId});

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  bool _loading = false;
  Object? _error;

  String? get _token => context.read<AuthProvider>().session?.token;

  int? get _tenantId => activeUserTenant(context)?.tenant.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureManagerLoaded());
  }

  /// ADR-021: el encargado ya no viene embebido en `GET /organization-units`
  /// -- se carga aparte al entrar al detalle (`GET
  /// /organization-units/{id}/manager`), una sola vez por unidad.
  Future<void> _ensureManagerLoaded() async {
    final provider = context.read<OrganizationUnitsProvider>();
    if (provider.isManagerLoaded(widget.unitId)) return;
    final tenantId = _tenantId;
    final token = _token;
    if (tenantId == null || token == null) return;
    try {
      await provider.loadManager(widget.unitId, tenantId, token);
    } catch (_) {
      // Silencioso -- la sección "Encargado" simplemente no se resuelve, el
      // resto del detalle sigue funcionando.
    }
  }

  Future<void> _ensureRolesLoaded(int tenantId) async {
    final rolesProvider = context.read<RolesProvider>();
    if (rolesProvider.isLoaded(tenantId)) return;
    final token = _token;
    if (token == null) return;
    await rolesProvider.load(tenantId, token);
  }

  /// Recarga forzada de toda la lista -- solo se llama desde pull-to-refresh
  /// y "Reintentar" (no existe `GET /organization-units/{id}`), mismo patrón
  /// que `StructureTab._load`.
  Future<void> _load() async {
    final tenantId = _tenantId;
    final token = _token;
    if (tenantId == null || token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<OrganizationUnitsProvider>().load(tenantId, token, context.read<TenantUsersProvider>());
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _applyPatch(int tenantId, OrganizationUnit patchedUnit) {
    context.read<OrganizationUnitsProvider>().applyUpdate(tenantId, DepartmentSummary(unit: patchedUnit));
  }

  Future<void> _openEdit(OrganizationUnit unit, int tenantId) async {
    final updated = await showModalBottomSheet<OrganizationUnit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateEditDepartmentBottomSheet(tenantId: tenantId, existing: unit),
    );
    if (updated == null || !mounted) return;
    // La respuesta de PUT no trae `members` embebido -- se preservan los que
    // ya se tenían en el cache.
    _applyPatch(tenantId, updated.copyWith(members: unit.members));
  }

  Future<void> _openAssignMember(OrganizationUnit unit, int tenantId) async {
    final activeMemberIds = unit.members.where((m) => m.isActive).map((m) => m.userId).toSet();
    final candidates = context.read<TenantUsersProvider>().membersFor(tenantId).where((u) => !activeMemberIds.contains(u.userId)).toList();

    final userId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignMemberBottomSheet(candidates: candidates),
    );
    if (userId == null || !mounted) return;

    final token = _token;
    if (token == null) return;
    try {
      final member = await OrganizationUnitInjection.organizationUnitMemberActionsController().assign(unit.id, tenantId, userId, token);
      if (!mounted) return;
      _applyPatch(tenantId, unit.copyWith(members: [...unit.members, member]));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _openAssignManager(OrganizationUnit unit, int tenantId, List<TenantMember> activeMemberProfiles) async {
    if (activeMemberProfiles.isEmpty) return;
    final userId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssignManagerBottomSheet(activeMembers: activeMemberProfiles),
    );
    if (userId == null || !mounted) return;

    final token = _token;
    if (token == null) return;
    final hasManager = context.read<OrganizationUnitsProvider>().managerFor(unit.id) != null;
    try {
      final actions = OrganizationUnitInjection.organizationUnitManagerActionsController();
      if (hasManager) {
        await actions.transfer(unit.id, tenantId, userId, token);
      } else {
        // Asignar (a diferencia de transferir) exige elegir qué Role recibe
        // el encargado -- ya no hay un "rol de encargado" fijo (ADR-021).
        await _ensureRolesLoaded(tenantId);
        if (!mounted) return;
        final roles = context.read<RolesProvider>().rolesFor(tenantId);
        final role = await showModalBottomSheet<Role>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AssignRoleBottomSheet(roles: roles),
        );
        if (role == null || !mounted) return;
        await actions.assign(unit.id, tenantId, userId, role.id, token);
      }
      if (!mounted) return;

      // Ninguna de las acciones de encargado devuelve el encargado
      // actualizado -- se parchea en memoria con el `userId` recién enviado,
      // nunca con un GET completo.
      context.read<OrganizationUnitsProvider>().setManager(
            unit.id,
            UnitManager(userId: userId, organizationUnitId: unit.id, grantedAt: DateTime.now()),
          );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _removeManager(OrganizationUnit unit, int tenantId, TenantMember? managerProfile) async {
    final confirmed = await _confirm(
      title: '¿Remover encargado?',
      content: '${managerProfile?.fullName ?? 'El encargado actual'} dejará de ser el encargado de este departamento.',
      confirmLabel: 'Remover',
    );
    if (confirmed != true) return;

    final token = _token;
    if (token == null) return;
    try {
      await OrganizationUnitInjection.organizationUnitManagerActionsController().remove(unit.id, tenantId, token);
      if (!mounted) return;
      context.read<OrganizationUnitsProvider>().setManager(unit.id, null);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleActive(OrganizationUnit unit, int tenantId) async {
    final activating = !unit.isActive;
    final confirmed = await _confirm(
      title: activating ? '¿Activar departamento?' : '¿Desactivar departamento?',
      content: activating
          ? 'El departamento volverá a estar disponible.'
          : 'El departamento dejará de estar activo. Podrás reactivarlo desde aquí cuando quieras.',
      confirmLabel: activating ? 'Activar' : 'Desactivar',
    );
    if (confirmed != true) return;

    final token = _token;
    if (token == null) return;
    try {
      final updated = await OrganizationUnitInjection.updateOrganizationUnitController().update(
        id: unit.id,
        tenantId: tenantId,
        name: unit.name,
        description: unit.description,
        parentUnitId: unit.parentUnitId,
        status: activating ? 'ACTIVE' : 'INACTIVE',
        token: token,
      );
      if (!mounted) return;
      _applyPatch(tenantId, updated.copyWith(members: unit.members));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _delete(OrganizationUnit unit, int tenantId) async {
    final activeCount = unit.members.where((m) => m.isActive).length;
    final confirmed = await _confirm(
      title: '¿Eliminar departamento?',
      content: activeCount > 0
          ? 'Este departamento tiene $activeCount ${activeCount == 1 ? 'miembro activo' : 'miembros activos'}. Se eliminará de todas formas.'
          : 'Esta acción desactiva el departamento de forma permanente.',
      confirmLabel: 'Eliminar',
      danger: true,
    );
    if (confirmed != true) return;

    final token = _token;
    if (token == null) return;
    try {
      await OrganizationUnitInjection.deleteOrganizationUnitController().delete(unit.id, tenantId, token);
      if (!mounted) return;
      // El endpoint solo devuelve `successfully`/`message` (soft-delete:
      // siempre queda INACTIVE) -- se refleja localmente.
      _applyPatch(tenantId, unit.copyWith(status: 'INACTIVE'));
      Navigator.of(context).pop();
    } catch (e) {
      _showError(e);
    }
  }

  Future<bool?> _confirm({required String title, required String content, required String confirmLabel, bool danger = false}) {
    final colors = AppColors.of(context, listen: false);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: danger ? FilledButton.styleFrom(backgroundColor: colors.danger) : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showError(Object e) {
    if (!mounted) return;
    final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenantId = _tenantId;
    DepartmentSummary? summary;
    if (tenantId != null) {
      for (final s in context.watch<OrganizationUnitsProvider>().summariesFor(tenantId)) {
        if (s.unit.id == widget.unitId) {
          summary = s;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: const Padding(padding: EdgeInsets.only(left: 20), child: AppBackButton()),
        title: Text(summary?.unit.name ?? 'Departamento', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(colors)
              : summary == null || tenantId == null
                  ? Center(
                      child: Text('No se encontró el departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _buildBody(colors, summary.unit, tenantId),
                    ),
    );
  }

  Widget _buildBody(AppPalette colors, OrganizationUnit unit, int tenantId) {
    final usersById = {for (final u in context.watch<TenantUsersProvider>().membersFor(tenantId)) u.userId: u};
    final activeMemberProfiles = unit.members.where((m) => m.isActive).map((m) => usersById[m.userId]).whereType<TenantMember>().toList();
    final managerId = context.watch<OrganizationUnitsProvider>().managerFor(unit.id)?.userId;
    final managerProfile = managerId == null ? null : usersById[managerId];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        _buildInfoSection(colors, unit, tenantId),
        const SizedBox(height: AppSpacing.lg),
        MembersSection(
          activeMemberCount: activeMemberProfiles.length,
          onAssign: () => _openAssignMember(unit, tenantId),
        ),
        const SizedBox(height: AppSpacing.lg),
        ManagerSection(
          manager: managerProfile,
          hasActiveMembers: activeMemberProfiles.isNotEmpty,
          onAssign: () => _openAssignManager(unit, tenantId, activeMemberProfiles),
          onRemove: () => _removeManager(unit, tenantId, managerProfile),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildConfigSection(colors, unit, tenantId),
      ],
    );
  }

  Widget _buildError(AppPalette colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 32),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error is ApiException ? (_error as ApiException).message : 'Ocurrió un error inesperado.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppPalette colors, OrganizationUnit unit, int tenantId) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Información', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary))),
              TextButton.icon(
                onPressed: () => _openEdit(unit, tenantId),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine(label: 'Descripción', value: unit.description.isEmpty ? 'Sin descripción registrada' : unit.description, colors: colors),
          _InfoLine(label: 'Estado', value: unit.isActive ? 'Activo' : 'Inactivo', colors: colors),
          _InfoLine(
            label: 'Creado el',
            value: '${unit.createdAt.day.toString().padLeft(2, '0')}/${unit.createdAt.month.toString().padLeft(2, '0')}/${unit.createdAt.year}',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(AppPalette colors, OrganizationUnit unit, int tenantId) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuración', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined, color: colors.textSecondary),
            title: const Text('Editar departamento'),
            onTap: () => _openEdit(unit, tenantId),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              unit.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
              color: colors.textSecondary,
            ),
            title: Text(unit.isActive ? 'Desactivar departamento' : 'Activar departamento'),
            onTap: () => _toggleActive(unit, tenantId),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline_rounded, color: colors.danger),
            title: Text('Eliminar departamento', style: TextStyle(color: colors.danger)),
            onTap: () => _delete(unit, tenantId),
          ),
        ],
      ),
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
          SizedBox(width: 100, child: Text(label, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary))),
          Expanded(child: Text(value, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
