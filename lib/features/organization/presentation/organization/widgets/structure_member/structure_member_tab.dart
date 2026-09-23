import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/member_unit_relation.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/my_unit_join_requests_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

import '../structure/structure_no_results_state.dart';
import 'member_department_card.dart';
import 'member_unit_detail_screen.dart';
import 'structure_member_empty_state.dart';
import 'structure_member_summary_row.dart';

enum MemberStructureFilter { all, mine, available, requests }

/// Pestaña "Estructura Organizacional" de Organización (Member) -- ver
/// docs/01-features/organizacion.md. Solo explora/participa -- nunca
/// crea/edita/elimina departamentos ni gestiona miembros/encargados (eso es
/// exclusivo del Admin, ver `widgets/structure/`). Los departamentos viven
/// en `OrganizationUnitsProvider` (cache global por tenant, COMPARTIDA con
/// el lado Admin -- si cualquiera de los dos ya la cargó para este tenant,
/// el otro no repite `GET /organization-units`); las solicitudes propias
/// viven en `MyUnitJoinRequestsProvider` (cache global, sin tenantId). Esta
/// pestaña solo dispara `_load()` la primera vez que se visita cada
/// organización, o cuando el usuario pide pull-to-refresh.
class StructureMemberTab extends StatefulWidget {
  const StructureMemberTab({super.key});

  @override
  State<StructureMemberTab> createState() => StructureMemberTabState();
}

class StructureMemberTabState extends State<StructureMemberTab> with AutomaticKeepAliveClientMixin<StructureMemberTab> {
  @override
  bool get wantKeepAlive => true;

  bool _loading = true;
  Object? _error;
  int? _busyUnitId;

  final _searchController = TextEditingController();
  String _query = '';
  MemberStructureFilter _filter = MemberStructureFilter.all;

  int? get _tenantId {
    final auth = context.read<AuthProvider>();
    final tenants = auth.session?.user.tenants ?? [];
    final active = context.read<TenantSessionController>().resolveActive(tenants);
    return active?.tenant.id;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));

    final tenantId = _tenantId;
    if (tenantId != null &&
        context.read<OrganizationUnitsProvider>().isLoaded(tenantId) &&
        context.read<MyUnitJoinRequestsProvider>().isLoaded) {
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Recarga forzada -- es lo que de verdad hay detrás del pull-to-refresh,
  /// ignora si el tenant/las solicitudes ya estaban cacheados.
  Future<void> _load() async {
    final tenantId = _tenantId;
    final token = context.read<AuthProvider>().session?.token;
    if (tenantId == null || token == null) {
      setState(() {
        _loading = false;
        _error = Exception('No hay una organización activa.');
      });
      return;
    }

    final tenantUsersProvider = context.read<TenantUsersProvider>();
    final unitsProvider = context.read<OrganizationUnitsProvider>();
    final requestsProvider = context.read<MyUnitJoinRequestsProvider>();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await unitsProvider.load(tenantId, token, tenantUsersProvider);
      await requestsProvider.load(token);
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

  Future<void> _requestToJoin(OrganizationUnit unit) async {
    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    setState(() => _busyUnitId = unit.id);
    try {
      final result = await OrganizationUnitInjection.requestToJoinUnitController().requestToJoin(unit.id, token);
      if (!mounted) return;
      context.read<MyUnitJoinRequestsProvider>().applyResult(result.request);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _busyUnitId = null);
    }
  }

  Future<void> _cancelRequest(UnitJoinRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar solicitud?'),
        content: Text('Tu solicitud para unirte a "${request.organizationUnitName}" se cancelará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Volver')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancelar solicitud')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    setState(() => _busyUnitId = request.organizationUnitId);
    try {
      final updated = await OrganizationUnitInjection.cancelUnitJoinRequestController().cancel(request.id, token);
      if (!mounted) return;
      context.read<MyUnitJoinRequestsProvider>().applyResult(updated);
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _busyUnitId = null);
    }
  }

  void _showError(Object e) {
    final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDetail(int tenantId, DepartmentSummary summary) async {
    final usersById = {for (final u in context.read<TenantUsersProvider>().membersFor(tenantId)) u.userId: u};
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberUnitDetailScreen(unit: summary.unit, usersById: usersById)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError(context);

    final colors = AppColors.of(context);
    final tenantId = _tenantId;
    if (tenantId == null) return _buildError(context);

    final currentUserId = context.read<AuthProvider>().session?.user.id;
    final summaries = context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    final myRequests = context.watch<MyUnitJoinRequestsProvider>().requests;
    final latestByUnit = MemberUnitRelation.latestRequestByUnit(myRequests);

    final visible = <(DepartmentSummary, MemberUnitRelation)>[];
    for (final summary in summaries) {
      final relation = MemberUnitRelation.resolve(
        unit: summary.unit,
        currentUserId: currentUserId ?? -1,
        latestRequestForUnit: latestByUnit[summary.unit.id],
      );
      if (summary.unit.isActive || relation.status != MemberUnitRelationStatus.notMember) {
        visible.add((summary, relation));
      }
    }

    final myDepartments = visible.where((e) => e.$2.status == MemberUnitRelationStatus.member).length;
    final pendingRequests = visible.where((e) => e.$2.status == MemberUnitRelationStatus.pending).length;
    final availableDepartments = visible.where((e) => e.$2.status == MemberUnitRelationStatus.notMember).length;

    final byFilter = switch (_filter) {
      MemberStructureFilter.all => visible,
      MemberStructureFilter.mine => visible.where((e) => e.$2.status == MemberUnitRelationStatus.member).toList(),
      MemberStructureFilter.available => visible.where((e) => e.$2.status == MemberUnitRelationStatus.notMember).toList(),
      MemberStructureFilter.requests => visible
          .where((e) => e.$2.status == MemberUnitRelationStatus.pending || e.$2.status == MemberUnitRelationStatus.rejected)
          .toList(),
    };

    final filtered = _query.isEmpty ? byFilter : byFilter.where((e) => e.$1.unit.name.toLowerCase().contains(_query)).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StructureMemberSummaryRow(
                  myDepartments: myDepartments,
                  pendingRequests: pendingRequests,
                  availableDepartments: availableDepartments,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar departamento...',
                    prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderPill, borderSide: BorderSide(color: colors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderPill, borderSide: BorderSide(color: colors.border)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFilterChips(colors),
                const SizedBox(height: AppSpacing.lg),
                if (summaries.isEmpty)
                  const StructureMemberEmptyState(variant: StructureMemberEmptyVariant.noDepartments)
                else if (byFilter.isEmpty)
                  StructureMemberEmptyState(variant: _emptyVariantForFilter())
                else if (filtered.isEmpty)
                  StructureNoResultsState(query: _searchController.text.trim())
                else
                  for (final entry in filtered) ...[
                    MemberDepartmentCard(
                      summary: entry.$1,
                      relation: entry.$2,
                      busy: _busyUnitId == entry.$1.unit.id,
                      onTap: () => _openDetail(tenantId, entry.$1),
                      onRequestJoin: () => _requestToJoin(entry.$1.unit),
                      onCancelRequest: entry.$2.latestRequest == null
                          ? null
                          : () => _cancelRequest(entry.$2.latestRequest!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                const SizedBox(height: 88),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  StructureMemberEmptyVariant _emptyVariantForFilter() {
    return switch (_filter) {
      MemberStructureFilter.mine => StructureMemberEmptyVariant.noMemberships,
      MemberStructureFilter.requests => StructureMemberEmptyVariant.noRequests,
      _ => StructureMemberEmptyVariant.noDepartments,
    };
  }

  Widget _buildFilterChips(AppPalette colors) {
    final options = const [
      (MemberStructureFilter.all, 'Todos'),
      (MemberStructureFilter.mine, 'Mis departamentos'),
      (MemberStructureFilter.available, 'Disponibles'),
      (MemberStructureFilter.requests, 'Solicitudes'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _filter == option.$1,
              onSelected: (_) => setState(() => _filter = option.$1),
              labelStyle: AppTypography.labelMedium.copyWith(
                color: _filter == option.$1 ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              side: BorderSide(color: _filter == option.$1 ? colors.primary : colors.border),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = AppColors.of(context);
    final isForbidden = _error is ApiException && (_error as ApiException).statusCode == 403;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 32),
            const SizedBox(height: AppSpacing.md),
            Text(
              isForbidden
                  ? 'No tienes acceso para ver la estructura de esta organización.'
                  : (_error is ApiException ? (_error as ApiException).message : 'No hay una organización activa.'),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            if (!isForbidden) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
