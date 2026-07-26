import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/routing/route_registry.dart';
import 'profile/profile_screen.dart';
import 'change_password/change_password_screen.dart';

void registerUserRoutes() {
  RouteRegistry.instance.register(AppRoutes.profile, (_) => const ProfileScreen());
  RouteRegistry.instance.register(AppRoutes.changePassword, (_) => const ChangePasswordScreen());
}
