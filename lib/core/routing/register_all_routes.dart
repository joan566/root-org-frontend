import 'package:savings_api_frontend/features/dashboard/presentation/dashboard_routes.dart';
import 'package:savings_api_frontend/features/shell/presentation/shell_routes.dart';
import 'package:savings_api_frontend/features/tenant/presentation/tenant_routes.dart';
import 'package:savings_api_frontend/features/user/presentation/user_routes.dart';

/// Único punto que conoce todas las features con rutas dentro del shell.
/// Se llama una vez al iniciar la app (`main.dart`), antes de `runApp`.
void registerAllRoutes() {
  registerDashboardRoutes();
  registerTenantRoutes();
  registerUserRoutes();
  registerShellPlaceholderRoutes();
}
