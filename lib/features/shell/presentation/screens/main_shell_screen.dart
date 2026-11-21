import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../../core/design_system/components/feedback/app_loading_state.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../auth/presentation/state/auth_error_message.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    required this.controller,
    required this.location,
    required this.child,
    super.key,
  });

  final AuthController controller;
  final String location;
  final Widget child;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => switch (widget.controller.status) {
        AuthStatus.restoring => const Scaffold(
          body: AppLoadingState(message: 'Restaurando sesión...'),
        ),
        AuthStatus.restoreFailed => Scaffold(
          body: AppErrorState(
            title: 'No se pudo restaurar la sesión',
            message: AuthErrorMessage.from(
              widget.controller.restoreError ?? StateError('Unknown error'),
              fallback: 'Verifica tu conexión e inténtalo nuevamente.',
            ),
            onRetry: widget.controller.restore,
          ),
        ),
        AuthStatus.unauthenticated => const Scaffold(body: AppLoadingState()),
        AuthStatus.authenticated => _buildAuthenticatedLayout(context),
      },
    );
  }

  Widget _buildAuthenticatedLayout(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final canPop = context.canPop();
    final isHome = widget.location == RouteNames.home;
    final layout = isDesktop
        ? _buildDesktopLayout(context)
        : _buildMobileLayout(context);

    return PopScope<Object?>(
      canPop: isHome || canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !canPop && !isHome) {
          context.go(RouteNames.home);
        }
      },
      child: layout,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: _isSidebarCollapsed ? 'Expandir menú' : 'Contraer menú',
          onPressed: () {
            setState(() {
              _isSidebarCollapsed = !_isSidebarCollapsed;
            });
          },
          icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open),
        ),
        title: const Text(AppConstants.appName),
      ),
      body: Row(
        children: [
          _DesktopNavigation(
            isCollapsed: _isSidebarCollapsed,
            location: widget.location,
            onSignOut: () => _signOut(context),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mobileSelectedIndex(widget.location),
        onDestinationSelected: (index) {
          context.go(_mobileDestinations[index].location);
        },
        destinations: [
          for (final destination in _mobileDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await widget.controller.signOut();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo completar el cierre de sesión.'),
          ),
        );
      }
    }
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.isCollapsed,
    required this.location,
    required this.onSignOut,
  });

  final bool isCollapsed;
  final String location;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed ? 72.0 : 256.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(
                    context,
                    label: 'Inicio',
                    location: RouteNames.home,
                    icon: Icons.home_outlined,
                  ),
                  _section(context, 'INVENTARIO'),
                  _item(
                    context,
                    label: 'Existencias',
                    location: RouteNames.stocks,
                    icon: Icons.inventory_2_outlined,
                  ),
                  _item(
                    context,
                    label: 'Operaciones',
                    location: RouteNames.operations,
                    icon: Icons.swap_horiz,
                  ),
                  _item(
                    context,
                    label: 'Reservas',
                    location: RouteNames.reservations,
                    icon: Icons.bookmark_border,
                  ),
                  _item(
                    context,
                    label: 'Conteos',
                    location: RouteNames.counts,
                    icon: Icons.fact_check_outlined,
                  ),
                  _section(context, 'CATÁLOGO'),
                  _item(
                    context,
                    label: 'Productos',
                    location: RouteNames.products,
                    icon: Icons.widgets_outlined,
                  ),
                  _item(
                    context,
                    label: 'Categorías',
                    location: RouteNames.categories,
                    icon: Icons.category_outlined,
                  ),
                  _section(context, 'ORGANIZACIÓN'),
                  _item(
                    context,
                    label: 'Organizaciones',
                    location: RouteNames.organizations,
                    icon: Icons.account_tree_outlined,
                  ),
                  _item(
                    context,
                    label: 'Solicitudes',
                    location: RouteNames.requests,
                    icon: Icons.inbox_outlined,
                  ),
                  _section(context, 'CUENTA'),
                  _item(
                    context,
                    label: 'Perfil',
                    location: RouteNames.profile,
                    icon: Icons.person_outline,
                  ),
                ],
              ),
            ),
            _item(
              context,
              label: 'Cerrar sesión',
              location: '',
              icon: Icons.logout,
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String label) {
    if (isCollapsed) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required String label,
    required String location,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final selected = location.isNotEmpty && this.location == location;
    final colors = Theme.of(context).colorScheme;
    final tile = ListTile(
      selected: selected,
      selectedTileColor: colors.secondaryContainer,
      leading: Icon(icon),
      title: isCollapsed ? null : Text(label),
      minLeadingWidth: 24,
      contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 24 : 16),
      onTap: onTap ?? () => context.go(location),
    );

    return isCollapsed ? Tooltip(message: label, child: tile) : tile;
  }
}

class _MobileDestination {
  const _MobileDestination({
    required this.label,
    required this.location,
    required this.icon,
  });

  final String label;
  final String location;
  final IconData icon;
}

const _mobileDestinations = [
  _MobileDestination(
    label: 'Inicio',
    location: RouteNames.home,
    icon: Icons.home_outlined,
  ),
  _MobileDestination(
    label: 'Existencias',
    location: RouteNames.stocks,
    icon: Icons.inventory_2_outlined,
  ),
  _MobileDestination(
    label: 'Productos',
    location: RouteNames.products,
    icon: Icons.widgets_outlined,
  ),
  _MobileDestination(
    label: 'Operaciones',
    location: RouteNames.operations,
    icon: Icons.swap_horiz,
  ),
  _MobileDestination(
    label: 'Más',
    location: RouteNames.more,
    icon: Icons.more_horiz,
  ),
];

int _mobileSelectedIndex(String location) {
  if (location == RouteNames.home) return 0;
  if (location == RouteNames.stocks) return 1;
  if (location == RouteNames.products) return 2;
  if (location == RouteNames.operations ||
      location == RouteNames.reservations ||
      location == RouteNames.counts) {
    return 3;
  }
  return 4;
}
