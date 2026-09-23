import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'my_departments/my_departments_screen.dart';

void registerOrganizationUnitRoutes() {
  RouteRegistry.instance.register(
    AppRoutes.administration,
    (_) => const MyDepartmentsScreen(),
  );
}
