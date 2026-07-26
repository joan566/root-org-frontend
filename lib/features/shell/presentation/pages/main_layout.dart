import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/features/tenant/presentation/create_tenant/create_tenant_screen.dart';
import 'package:savings_api_frontend/features/tenant/presentation/join_tenant/join_tenant_screen.dart';
import 'package:savings_api_frontend/features/tenant/presentation/tenant_list/tenant_screen.dart';
import 'package:savings_api_frontend/features/user/presentation/change_password/change_password_screen.dart';
import 'package:savings_api_frontend/features/user/presentation/profile/profile_screen.dart';
import 'package:savings_api_frontend/features/dashboard/presentation/personal_dashboard/personal_dashboard_screen.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  late final NavigatorObserver _routeSyncObserver = _InnerRouteObserver(
    onRouteChanged: (routeName) {
      if (routeName == null) return;

      int? targetIndex;

      if (routeName == '/' || routeName == AppRoutes.dashboard) {
        targetIndex = 0;
      } else if (routeName == AppRoutes.tenants ||
          routeName == AppRoutes.createTenant ||
          routeName == AppRoutes.joinTenant) {
        targetIndex = 1;
      } else if (routeName == AppRoutes.profile ||
          routeName == AppRoutes.changePassword) {
        targetIndex = 3;
      }

      if (targetIndex != null && targetIndex != selectedIndex) {
        setState(() {
          selectedIndex = targetIndex!;
        });
      }
    },
  );

  void _onItemTapped(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        _innerNavigatorKey.currentState?.pushReplacementNamed('/');
        break;
      case 1:
        _innerNavigatorKey.currentState?.pushReplacementNamed(AppRoutes.tenants);
        break;
      case 2:
      // Espacio reservado para pantalla de Usuarios
        break;
      case 3:
        _innerNavigatorKey.currentState?.pushReplacementNamed(AppRoutes.profile);
        break;
    }
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
        page = const PersonalDashboardScreen();
        break;
      case AppRoutes.tenants:
        page = const TenantScreen();
        break;
      case AppRoutes.profile:
        page = const ProfileScreen();
        break;
      case AppRoutes.createTenant:
        page = const CreateTenantScreen();
        break;
      case AppRoutes.joinTenant:
        page = const JoinTenantScreen();
        break;
      case AppRoutes.changePassword:
        page = const ChangePasswordScreen();
        break;
      default:
        page = const PersonalDashboardScreen();
    }

    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final NavigatorState? navigator = _innerNavigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: Navigator(
          key: _innerNavigatorKey,
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
          observers: [_routeSyncObserver],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: const CircleBorder(),
          onPressed: () {
            _innerNavigatorKey.currentState?.pushNamed(AppRoutes.createTenant);
          },
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildItem(0, Icons.dashboard_rounded, "Inicio"),
                  _buildItem(1, Icons.groups_rounded, "Organizaciones"),
                  const SizedBox(width: 35),
                  _buildItem(2, Icons.people_alt_rounded, "Usuarios"),
                  _buildItem(3, Icons.person_rounded, "Perfil"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    final selected = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InnerRouteObserver extends NavigatorObserver {
  final Function(String?) onRouteChanged;

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
