import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'dashboard_general/dashboard_general_screen.dart';

void registerDashboardRoutes() {
  RouteRegistry.instance.register(
    AppRoutes.dashboard,
    (_) => const DashboardGeneralScreen(),
  );
}
