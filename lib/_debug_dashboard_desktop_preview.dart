import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_theme.dart';
import 'package:savings_api_frontend/core/design_system/colors/theme_controller.dart';
import 'package:savings_api_frontend/core/routing/register_all_routes.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/login_sesion.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_shell_screen.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';

// Solo para vista previa visual del rediseno mobile del dashboard, NO se
// commitea. Abrir la ventana angosta (ver window-size al lanzar) para ver
// la rama mobile de MainShellScreen/DashboardGeneralScreen.
void main() {
  registerAllRoutes();

  final tenant = Tenant(
    id: 1,
    name: 'Iglesia Central Cartagena',
    description: 'Fondo de ahorro y bienestar para la comunidad de la iglesia.',
    code: 'ICC-001',
  );
  final userTenant = UserTenant(id: 1, tenant: tenant, userId: 1, roles: const ['OWNER'], status: 'ACTIVE');
  final secondTenant = Tenant(
    id: 2,
    name: 'Cooperativa Manos Unidas',
    description: 'Cooperativa de ahorro y credito.',
    code: 'CMU-002',
  );
  final userTenant2 = UserTenant(id: 2, tenant: secondTenant, userId: 1, roles: const ['ADMIN'], status: 'ACTIVE');

  final user = User(
    id: 1,
    name: 'Joan',
    lastName: 'Vergara',
    document: '123456789',
    dateOfBirth: DateTime(1995, 1, 1),
    gender: 'M',
    email: 'joan@example.com',
    phoneNumber: '3001234567',
    status: 'ACTIVE',
    profileStatus: 'Completo',
    tenants: [userTenant, userTenant2],
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01',
  );

  final session = LoginSesion(token: 'debug-token', hasTenant: true, user: user);

  final authProvider = AuthProvider()..login(session);
  final tenantSession = TenantSessionController()
    ..setActive(userTenant)
    ..markGatePassed();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<TenantSessionController>.value(value: tenantSession),
        ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.mode,
            home: const MainShellScreen(),
          );
        },
      ),
    ),
  );
}
