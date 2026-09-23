import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';

import 'home/department_home_screen.dart';
import 'info/department_info_screen.dart';
import 'join_requests/department_join_requests_screen.dart';
import 'members/department_members_screen.dart';
import 'roles/department_roles_screen.dart';

/// Shell del Workspace de un departamento -- cambia por completo el
/// contexto de navegación (ver docs/01-features/organizacion.md
/// §"Workspace"): header propio con "Volver a la organización" + un
/// `Navigator` interno propio para sus herramientas (Centro de Trabajo,
/// Miembros, Roles, Solicitudes, Información). Solo recibe `unitId` -- todo
/// lo demás (tenant activo, usuario actual, capacidades) se resuelve en
/// vivo en cada pantalla, nunca se cachea aquí (ver razonamiento en
/// `workspace_lookup.dart`).
class DepartmentWorkspaceScreen extends StatefulWidget {
  final int unitId;

  const DepartmentWorkspaceScreen({super.key, required this.unitId});

  @override
  State<DepartmentWorkspaceScreen> createState() => _DepartmentWorkspaceScreenState();
}

class _DepartmentWorkspaceScreenState extends State<DepartmentWorkspaceScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _atHome = true;

  late final NavigatorObserver _depthObserver = _WorkspaceRouteObserver(
    onDepthChanged: (atHome) {
      if (atHome != _atHome && mounted) setState(() => _atHome = atHome);
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureManagerLoaded();
      _ensurePermissionsLoaded();
    });
  }

  /// Todas las herramientas del Workspace (Home, Roles, Miembros,
  /// Información) necesitan saber quién es el encargado -- se carga una sola
  /// vez al entrar (ADR-021: `GET /organization-units/{id}/manager`, ya no
  /// viene embebido en la unidad), no por cada herramienta.
  Future<void> _ensureManagerLoaded() async {
    final provider = context.read<OrganizationUnitsProvider>();
    if (provider.isManagerLoaded(widget.unitId)) return;
    final tenantId = activeUserTenant(context)?.tenant.id;
    final token = context.read<AuthProvider>().session?.token;
    if (tenantId == null || token == null) return;
    try {
      await provider.loadManager(widget.unitId, tenantId, token);
    } catch (_) {
      // Silencioso -- cada herramienta ya maneja su propio estado de error
      // para sus propias cargas; el encargado es un dato secundario aquí.
    }
  }

  /// Igual que el encargado: se resuelve una sola vez al entrar al
  /// Workspace (ADR-021: `GET /me/permissions?tenantId=&organizationUnitId=`),
  /// y cada herramienta (Home, Roles, Miembros) lee del mismo cache en vez
  /// de pedirlo por su cuenta.
  Future<void> _ensurePermissionsLoaded() async {
    final provider = context.read<PermissionsProvider>();
    final tenantId = activeUserTenant(context)?.tenant.id;
    final token = context.read<AuthProvider>().session?.token;
    if (tenantId == null || token == null) return;
    if (provider.isUnitLoaded(tenantId, widget.unitId)) return;
    try {
      await provider.loadForUnit(tenantId, widget.unitId, token);
    } catch (_) {
      // Silencioso -- sin permisos resueltos, las herramientas simplemente
      // no muestran sus acciones (fail-closed).
    }
  }

  void _goBack(BuildContext context) {
    final navState = _navigatorKey.currentState;
    if (navState != null && navState.canPop()) {
      navState.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final Widget screen;
    switch (settings.name) {
      case 'members':
        screen = DepartmentMembersScreen(unitId: widget.unitId);
        break;
      case 'roles':
        screen = DepartmentRolesScreen(unitId: widget.unitId);
        break;
      case 'join_requests':
        screen = DepartmentJoinRequestsScreen(unitId: widget.unitId);
        break;
      case 'info':
        screen = DepartmentInfoScreen(unitId: widget.unitId);
        break;
      default:
        screen = DepartmentHomeScreen(
          unitId: widget.unitId,
          onOpenTool: (route) => _navigatorKey.currentState?.pushNamed(route),
        );
    }
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenantId = activeUserTenant(context)?.tenant.id;
    final summaries = tenantId == null ? const <DepartmentSummary>[] : context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    DepartmentSummary? summary;
    for (final s in summaries) {
      if (s.unit.id == widget.unitId) {
        summary = s;
        break;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  children: [
                    AppBackButton(onPressed: () => _goBack(context)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _atHome ? 'Volver a la organización' : 'Volver',
                            style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                          ),
                          Text(
                            summary?.unit.name ?? 'Departamento',
                            style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: colors.border, height: 1),
              Expanded(
                child: Navigator(
                  key: _navigatorKey,
                  onGenerateRoute: _onGenerateRoute,
                  observers: [_depthObserver],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceRouteObserver extends NavigatorObserver {
  final void Function(bool atHome) onDepthChanged;

  _WorkspaceRouteObserver({required this.onDepthChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onDepthChanged(route.settings.name == null || route.settings.name == '/');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onDepthChanged(previousRoute?.settings.name == null || previousRoute?.settings.name == '/');
  }
}
