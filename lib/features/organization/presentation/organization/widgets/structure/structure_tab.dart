import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

import 'create_edit_department_bottom_sheet.dart';
import 'department_card.dart';
import 'structure_empty_state.dart';
import 'structure_no_results_state.dart';
import 'structure_summary_row.dart';
import 'unit_detail_screen.dart';

/// Pestaña "Estructura" de Organización (Admin) -- gestión de
/// `OrganizationUnit` ("departamentos"). Ver docs/01-features/organizacion.md
/// y el plan de Estructura Organizacional. Los datos viven en
/// `OrganizationUnitsProvider` (cache global por tenant, registrado en
/// `main.dart`), no en el estado de este widget -- así sobreviven a navegar
/// fuera de Organización y volver, no solo a cambiar de pestaña. Este widget
/// solo dispara `load()` la primera vez que se visita cada organización en
/// la sesión, o cuando el usuario pide pull-to-refresh.
class StructureTab extends StatefulWidget {
  const StructureTab({super.key});

  @override
  State<StructureTab> createState() => StructureTabState();
}

class StructureTabState extends State<StructureTab> with AutomaticKeepAliveClientMixin<StructureTab> {
  @override
  bool get wantKeepAlive => true;

  bool _loading = true;
  Object? _error;

  final _searchController = TextEditingController();
  String _query = '';

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
    if (tenantId != null && context.read<OrganizationUnitsProvider>().isLoaded(tenantId)) {
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

  /// Punto de entrada público para abrir el formulario de creación --
  /// invocado tanto por el FAB de `OrganizationScreen` (vía `GlobalKey`,
  /// ver `_buildFab`) como por el botón del estado vacío de esta pestaña,
  /// para no duplicar el flujo en dos lugares.
  Future<void> openCreate() async {
    final tenantId = _tenantId;
    if (tenantId == null) return;
    final created = await showModalBottomSheet<OrganizationUnit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateEditDepartmentBottomSheet(tenantId: tenantId),
    );
    if (created == null || !mounted) return;
    context.read<OrganizationUnitsProvider>().add(tenantId, DepartmentSummary(unit: created));
  }

  /// Recarga forzada -- es lo que de verdad hay detrás del pull-to-refresh,
  /// ignora si el tenant ya estaba cacheado.
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

  Future<void> _openDetail(DepartmentSummary summary) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UnitDetailScreen(unitId: summary.unit.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError(context);

    final colors = AppColors.of(context);
    final tenantId = _tenantId;
    final summaries = tenantId == null ? const <DepartmentSummary>[] : context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    final filtered = _query.isEmpty ? summaries : summaries.where((s) => s.unit.name.toLowerCase().contains(_query)).toList();

    final totalMembers = summaries.fold<int>(0, (sum, s) => sum + s.memberCount);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StructureSummaryRow(
                  totalDepartments: summaries.length,
                  totalMembers: totalMembers,
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
                const SizedBox(height: AppSpacing.lg),
                if (summaries.isEmpty)
                  StructureEmptyState(onCreate: openCreate)
                else if (filtered.isEmpty)
                  StructureNoResultsState(query: _searchController.text.trim())
                else
                  for (final summary in filtered) ...[
                    DepartmentCard(
                      summary: summary,
                      onTap: () => _openDetail(summary),
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
                  : (_error is ApiException ? (_error as ApiException).message : 'Ocurrió un error inesperado.'),
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
