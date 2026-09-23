import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/breakpoints/breakpoints.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import '../widgets/shell_bottom_nav.dart';
import '../widgets/shell_header.dart';
import '../widgets/shell_header_mobile.dart';
import '../widgets/shell_section.dart';
import '../widgets/shell_sidebar.dart';

/// Layout principal de la app autenticada (reemplaza a `MainLayout`, ver
/// docs/frontend-navigation-redesign.md). Desktop: sidebar fija con las 5
/// secciones principales. Mobile: bottom nav adaptativa. Ambas comparten el
/// mismo `Navigator` interno, resuelto contra `RouteRegistry` en vez de un
/// switch centralizado.
class MainShellScreen extends StatefulWidget {
  /// Ruta a empujar sobre `AppRoutes.dashboard` apenas monta el shell — ej.
  /// para entrar directo a "Crear organización" o "Completar perfil" desde
  /// el gate de selección de organización (`MyOrganizationsScreen`). El
  /// dashboard queda debajo en la pila, así que el botón atrás funciona
  /// normalmente. `null` (default) entra solo al dashboard, como siempre.
  final String? initialPushRoute;

  const MainShellScreen({super.key, this.initialPushRoute});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int selectedIndex = 0;

  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  TenantSessionController? _tenantSession;
  int? _activeTenantId;

  @override
  void initState() {
    super.initState();
    final route = widget.initialPushRoute;
    if (route != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _innerNavigatorKey.currentState?.pushNamed(route);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tenantSession = context.read<TenantSessionController>();
    if (!identical(_tenantSession, tenantSession)) {
      _tenantSession?.removeListener(_onTenantSessionChanged);
      _tenantSession = tenantSession;
      tenantSession.addListener(_onTenantSessionChanged);
      _activeTenantId = _resolveActiveTenantId();
    }
  }

  @override
  void dispose() {
    _tenantSession?.removeListener(_onTenantSessionChanged);
    super.dispose();
  }

  int? _resolveActiveTenantId() {
    final tenants = context.read<AuthProvider>().session?.user.tenants ?? const [];
    return context.read<TenantSessionController>().resolveActive(tenants)?.tenant.id;
  }

  /// Reacciona a cambios en la organización activa -- ver
  /// docs/00-core/07-refactor-arquitectura-frontend (fix de navegación):
  /// cambiar de org a mitad de sesión estando varios niveles profundo en el
  /// navigator interno (ej. dentro de `DepartmentWorkspaceScreen`) dejaba al
  /// usuario atascado, porque el stack seguía apuntando a datos de la org
  /// anterior. `TenantSessionController.clear()` (logout) también dispara
  /// este listener -- se descarta explícitamente vía `hasPassedGate`, ya que
  /// ahí el shell está a punto de desmontarse, no es un cambio de org real.
  void _onTenantSessionChanged() {
    if (!mounted) return;
    final tenantSession = context.read<TenantSessionController>();
    if (!tenantSession.hasPassedGate) return;

    final newActiveTenantId = _resolveActiveTenantId();
    if (newActiveTenantId == _activeTenantId) return;

    _activeTenantId = newActiveTenantId;
    setState(() => selectedIndex = 0);
    _innerNavigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }

  static const List<ShellSection> _sections = [
    ShellSection(label: 'Dashboard', icon: Icons.dashboard_outlined, route: AppRoutes.dashboard),
    ShellSection(label: 'Organización', icon: Icons.apartment_outlined, route: AppRoutes.organization),
    ShellSection(label: 'Módulos', icon: Icons.widgets_outlined, route: AppRoutes.modules),
    ShellSection(
      label: 'Mis Departamentos',
      icon: Icons.admin_panel_settings_outlined,
      route: AppRoutes.administration,
    ),
    ShellSection(
      label: 'Configuración',
      icon: Icons.settings_outlined,
      route: AppRoutes.profile,
      relatedRoutes: [AppRoutes.changePassword],
    ),
  ];

  late final NavigatorObserver _routeSyncObserver = _InnerRouteObserver(
    onRouteChanged: (routeName) {
      if (routeName == null) return;
      final targetIndex = _sections.indexWhere((s) => s.matchesRoute(routeName));
      if (targetIndex != -1 && targetIndex != selectedIndex) {
        setState(() => selectedIndex = targetIndex);
      }
    },
  );

  void _onItemTapped(int index) {
    if (selectedIndex == index) return;
    setState(() => selectedIndex = index);
    _innerNavigatorKey.currentState?.pushNamedAndRemoveUntil(_sections[index].route, (route) => false);
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final builder = RouteRegistry.instance.resolve(settings.name) ??
        RouteRegistry.instance.resolve(AppRoutes.dashboard)!;
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = Breakpoints.isDesktopContext(context);

    final navigator = Navigator(
      key: _innerNavigatorKey,
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: _onGenerateRoute,
      observers: [_routeSyncObserver],
    );

    final Widget scaffold = isDesktop
        ? Scaffold(
            backgroundColor: colors.background,
            body: Column(
              children: [
                const ShellHeader(),
                Expanded(
                  child: Row(
                    children: [
                      ShellSidebar(sections: _sections, selectedIndex: selectedIndex, onSelect: _onItemTapped),
                      Expanded(child: navigator),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: colors.background,
            body: Column(
              children: [
                const ShellHeaderMobile(),
                Expanded(child: navigator),
              ],
            ),
            bottomNavigationBar: ShellBottomNav(
              sections: _sections,
              selectedIndex: selectedIndex,
              onSelect: _onItemTapped,
            ),
          );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final NavigatorState? navState = _innerNavigatorKey.currentState;
        if (navState != null && navState.canPop()) {
          navState.pop();
        }
      },
      child: scaffold,
    );
  }
}

class _InnerRouteObserver extends NavigatorObserver {
  final void Function(String?) onRouteChanged;

  _InnerRouteObserver({required this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onRouteChanged(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onRouteChanged(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onRouteChanged(newRoute?.settings.name);
  }
}
