import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../core/design_system/components/feedback/app_error_state.dart';
import '../../../../core/design_system/components/feedback/app_loading_state.dart';
import '../screens/change_password/change_password_screen.dart';
import '../screens/email_verification/email_verification_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../state/auth_controller.dart';
import '../state/auth_error_message.dart';

abstract final class AuthRoutes {
  static const signIn = '/auth/sign-in';
  static const register = '/auth/register';
  static const emailVerification = '/auth/email-verification';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';

  static List<RouteBase> build(AuthController controller) => [
    GoRoute(
      path: '/',
      builder: (context, state) => _AuthHomeScreen(controller: controller),
    ),
    GoRoute(
      path: signIn,
      builder: (context, state) => SignInScreen(controller: controller),
    ),
    GoRoute(
      path: register,
      builder: (context, state) => RegisterScreen(controller: controller),
    ),
    GoRoute(
      path: emailVerification,
      builder: (context, state) => EmailVerificationScreen(
        controller: controller,
        email: state.uri.queryParameters['email'] ?? '',
      ),
    ),
    GoRoute(
      path: forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(controller: controller),
    ),
    GoRoute(
      path: resetPassword,
      builder: (context, state) {
        final extra = state.extra;
        final tokenFromExtra = extra is String ? extra : null;
        final tokenFromUrl = state.uri.queryParameters['resetToken'];
        return ResetPasswordScreen(
          controller: controller,
          resetToken: tokenFromExtra ?? tokenFromUrl,
          removeTokenFromUrl: tokenFromExtra == null && tokenFromUrl != null,
        );
      },
    ),
    GoRoute(
      path: changePassword,
      builder: (context, state) => ChangePasswordScreen(controller: controller),
    ),
  ];
}

class _AuthHomeScreen extends StatelessWidget {
  const _AuthHomeScreen({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return switch (controller.status) {
          AuthStatus.restoring => const Scaffold(
            body: AppLoadingState(message: 'Restaurando sesión...'),
          ),
          AuthStatus.restoreFailed => Scaffold(
            body: AppErrorState(
              title: 'No se pudo restaurar la sesión',
              message: AuthErrorMessage.from(
                controller.restoreError ?? StateError('Unknown error'),
                fallback: 'Verifica tu conexión e inténtalo nuevamente.',
              ),
              onRetry: controller.restore,
            ),
          ),
          AuthStatus.unauthenticated => const Scaffold(body: AppLoadingState()),
          AuthStatus.authenticated => Scaffold(
            appBar: AppBar(
              title: const Text('RootOrg'),
              actions: [
                IconButton(
                  tooltip: 'Cambiar contraseña',
                  onPressed: () => context.go(AuthRoutes.changePassword),
                  icon: const Icon(Icons.lock_outline),
                ),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sesión iniciada',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                          controller.session?.user.name,
                          controller.session?.user.lastName,
                        ]
                        .whereType<String>()
                        .where((name) => name.isNotEmpty)
                        .join(' '),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Cerrar sesión',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => _signOut(context),
                  ),
                ],
              ),
            ),
          ),
        };
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await controller.signOut();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo completar el cierre de sesión.'),
          ),
        );
      }
    }
  }
}
