import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_injection.dart';
import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../config/app_config.dart';
import '../design_system/themes/theme_controller.dart';
import '../network/api_client.dart';
import '../network/network_status.dart';
import '../routing/app_router.dart';
import '../security/secure_storage.dart';
import '../storage/local_storage.dart';

final class AppDependencies {
  const AppDependencies({
    required this.config,
    required this.localStorage,
    required this.secureStorage,
    required this.apiClient,
    required this.networkStatus,
    required this.router,
    required this.themeController,
    required this.authController,
  });

  final AppConfig config;
  final LocalStorage localStorage;
  final SecureStorage secureStorage;
  final ApiClient apiClient;
  final NetworkStatus networkStatus;
  final AppRouter router;
  final ThemeController themeController;
  final AuthController authController;
}

abstract final class DependencyInjection {
  static Future<AppDependencies> initialize() async {
    final config = AppConfig.fromEnvironment();
    final preferences = await SharedPreferences.getInstance();
    final secureStorage = SecureStorage();
    final localStorage = LocalStorage(preferences);
    final apiClient = ApiClient(config: config, secureStorage: secureStorage);
    final authController = AuthInjection.create(
      dio: apiClient.dio,
      secureStorage: secureStorage,
    );
    apiClient.installTokenRefreshHandler(authController);
    final router = AppRouter(
      routes: AuthRoutes.build(authController),
      refreshListenable: authController,
      redirect: authController.redirect,
    );
    unawaited(authController.restore());

    return AppDependencies(
      config: config,
      localStorage: localStorage,
      secureStorage: secureStorage,
      apiClient: apiClient,
      networkStatus: ConnectivityNetworkStatus(connectivity: Connectivity()),
      router: router,
      themeController: await ThemeController.load(localStorage),
      authController: authController,
    );
  }
}
