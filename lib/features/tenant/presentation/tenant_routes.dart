import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'tenant_list/tenant_screen.dart';
import 'create_tenant/create_tenant_screen.dart';
import 'join_tenant/join_tenant_screen.dart';

void registerTenantRoutes() {
  RouteRegistry.instance.register(AppRoutes.tenants, (_) => const TenantScreen());
  RouteRegistry.instance.register(AppRoutes.createTenant, (_) => const CreateTenantScreen());
  RouteRegistry.instance.register(AppRoutes.joinTenant, (_) => const JoinTenantScreen());
}
