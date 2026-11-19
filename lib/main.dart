import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/design_system/themes/app_theme.dart';
import 'core/design_system/themes/theme_controller.dart';
import 'core/network/api_client.dart';
import 'core/network/network_status.dart';
import 'core/routing/app_router.dart';
import 'core/security/secure_storage.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/presentation/state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await DependencyInjection.initialize();

  runApp(MainApp(dependencies: dependencies));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: dependencies.config),
        Provider<LocalStorage>.value(value: dependencies.localStorage),
        Provider<SecureStorage>.value(value: dependencies.secureStorage),
        Provider<NetworkStatus>.value(value: dependencies.networkStatus),
        Provider<ApiClient>(
          create: (_) => dependencies.apiClient,
          dispose: (_, apiClient) => apiClient.close(),
        ),
        Provider<AppRouter>(
          create: (_) => dependencies.router,
          dispose: (_, appRouter) => appRouter.dispose(),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => dependencies.themeController,
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => dependencies.authController,
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          routerConfig: dependencies.router.router,
        ),
      ),
    );
  }
}
