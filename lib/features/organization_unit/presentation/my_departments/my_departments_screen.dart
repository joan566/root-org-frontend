import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

import '../workspace/department_workspace_screen.dart';

/// Pantalla de entrada al trabajo diario departamental -- "¿a qué
/// departamento entro a trabajar?", no "¿qué unidad administro?" (eso sigue
/// siendo Organización→Estructura). Ver docs/01-features/organizacion.md
/// §"Workspace" -- por qué vive en `organization_unit` y no en una feature
/// de navegación aparte. Reutiliza el mismo `OrganizationUnitsProvider` que
/// ya usa esa pestaña -- si cualquiera de las dos ya lo cargó para el
/// tenant activo, la otra no repite `GET /organization-units`.
class MyDepartmentsScreen extends StatefulWidget {
  const MyDepartmentsScreen({super.key});

  @override
  State<MyDepartmentsScreen> createState() => _MyDepartmentsScreenState();
}

class _MyDepartmentsScreenState extends State<MyDepartmentsScreen> {
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final tenantId = activeUserTenant(context)?.tenant.id;
    if (tenantId != null && context.read<OrganizationUnitsProvider>().isLoaded(tenantId)) {
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureManagersLoaded());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    final tenantId = activeUserTenant(context)?.tenant.id;
    final token = context.read<AuthProvider>().session?.token;
    if (tenantId == null || token == null || !mounted) {
      setState(() {
        _loading = false;
        _error = tenantId == null ? Exception('No hay una organización activa.') : null;
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
      await _ensureManagersLoaded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /// Solo para los departamentos de los que el usuario ya es integrante
  /// activo (no toda la estructura del tenant -- ver ADR-021: el encargado
  /// ya no viene embebido, así que mostrar el badge "eres encargado" cuesta
  /// un `GET /organization-units/{id}/manager` por unidad; acotado a "mis
  /// departamentos" el conteo es chico, no el total de la organización).
  Future<void> _ensureManagersLoaded() async {
    final tenantId = activeUserTenant(context)?.tenant.id;
    final token = context.read<AuthProvider>().session?.token;
    final currentUserId = context.read<AuthProvider>().session?.user.id;
    if (tenantId == null || token == null || currentUserId == null || !mounted) return;

    final provider = context.read<OrganizationUnitsProvider>();
    final pendingUnitIds = provider
        .summariesFor(tenantId)
        .where((s) => s.unit.members.any((m) => m.userId == currentUserId && m.isActive))
        .map((s) => s.unit.id)
        .where((id) => !provider.isManagerLoaded(id));

    await Future.wait(pendingUnitIds.map((id) => provider.loadManager(id, tenantId, token).catchError((_) {})));
  }

  Future<void> _openWorkspace(int unitId) async {
    // rootNavigator: true empuja el Workspace por encima de MainShellScreen
    // (no del Navigator interno), para que su chrome de Organización
    // (sidebar/bottom-nav/header) desaparezca por completo mientras se está
    // dentro -- ver DepartmentWorkspaceScreen, que ya asume este contexto.
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => DepartmentWorkspaceScreen(unitId: unitId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.md),
              child: Text('Mis Departamentos', style: AppTypography.titleLarge.copyWith(color: colors.textPrimary)),
            ),
            Expanded(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppPalette colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
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
                    ? 'No tienes acceso a la estructura de esta organización.'
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

    final tenantId = activeUserTenant(context)?.tenant.id;
    final currentUserId = context.read<AuthProvider>().session?.user.id;
    final summaries = tenantId == null ? const <DepartmentSummary>[] : context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    final myDepartments = currentUserId == null
        ? const <DepartmentSummary>[]
        : summaries.where((s) => s.unit.members.any((m) => m.userId == currentUserId && m.isActive)).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: myDepartments.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Icon(Icons.groups_2_outlined, size: 40, color: colors.textMuted),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Todavía no perteneces a ningún departamento.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Puedes solicitar unirte a uno desde Organización → Estructura Organizacional.',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              itemCount: myDepartments.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final summary = myDepartments[index];
                final isManager = context.watch<OrganizationUnitsProvider>().managerFor(summary.unit.id)?.userId == currentUserId;
                return _DepartmentCard(
                  summary: summary,
                  isManager: isManager,
                  colors: colors,
                  onTap: () => _openWorkspace(summary.unit.id),
                );
              },
            ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final DepartmentSummary summary;
  final bool isManager;
  final AppPalette colors;
  final VoidCallback onTap;

  const _DepartmentCard({required this.summary, required this.isManager, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: colors.flatCardDecoration(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: colors.primary.withOpacity(0.12), borderRadius: AppRadius.borderMd),
                child: Icon(Icons.apartment_outlined, color: colors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.unit.name, style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.memberCount} ${summary.memberCount == 1 ? 'miembro' : 'miembros'}',
                      style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (isManager)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: colors.primary.withOpacity(0.12), borderRadius: AppRadius.borderPill),
                  child: Text('Encargado', style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
