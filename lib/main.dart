import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_routes.dart';
import 'core/routing/register_all_routes.dart';
import 'core/design_system/colors/theme_controller.dart';
import 'core/design_system/colors/app_theme.dart';
import 'core/session/tenant_session_controller.dart';
import 'features/auth/presentation/login/login_screen.dart';
import 'features/auth/presentation/register/register_screen.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/shell/presentation/pages/main_shell_screen.dart';
import 'features/tenant/presentation/select_tenant/select_tenant_screen.dart';

void main() {
  registerAllRoutes();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => TenantSessionController()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeController, TenantSessionController>(
      builder: (_, auth, themeController, tenantSession, __) {
        final Widget home;

        if (!auth.isLogged) {
          home = const LoginScreen();
        } else {
          final tenants = auth.session!.user.tenants;
          final activeTenant = tenantSession.resolveActive(tenants);
          home = (tenants.length > 1 && activeTenant == null)
              ? const SelectTenantScreen()
              : const MainShellScreen();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          home: home,
          routes: {
            AppRoutes.register: (_) => const RegisterScreen(),
          },
        );
      },
    );
  }
}
