import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'organization/organization_screen.dart';

void registerOrganizationRoutes() {
  RouteRegistry.instance.register(
    AppRoutes.organization,
    (_) => const OrganizationScreen(),
  );
}
