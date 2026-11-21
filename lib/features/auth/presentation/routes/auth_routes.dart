import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../../shell/presentation/screens/navigation_destination_screen.dart';
import '../screens/change_password/change_password_screen.dart';
import '../screens/email_verification/email_verification_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../state/auth_controller.dart';

abstract final class AuthRoutes {
  static const signIn = '/auth/sign-in';
  static const register = '/auth/register';
  static const emailVerification = '/auth/email-verification';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';

  static List<RouteBase> build(AuthController controller) => [
    ShellRoute(
      builder: (context, state, child) => MainShellScreen(
        controller: controller,
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Inicio'),
        ),
        GoRoute(
          path: RouteNames.stocks,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Existencias'),
        ),
        GoRoute(
          path: RouteNames.operations,
          builder: (context, state) => const NavigationDestinationScreen(
            title: 'Operaciones',
            links: [
              NavigationLink(
                label: 'Reservas',
                location: RouteNames.reservations,
                icon: Icons.bookmark_border,
              ),
              NavigationLink(
                label: 'Conteos',
                location: RouteNames.counts,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
        ),
        GoRoute(
          path: RouteNames.reservations,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Reservas'),
        ),
        GoRoute(
          path: RouteNames.counts,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Conteos'),
        ),
        GoRoute(
          path: RouteNames.products,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Productos'),
        ),
        GoRoute(
          path: RouteNames.categories,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Categorías'),
        ),
        GoRoute(
          path: RouteNames.organizations,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Organizaciones'),
        ),
        GoRoute(
          path: RouteNames.requests,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Solicitudes'),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) =>
              const NavigationDestinationScreen(title: 'Perfil'),
        ),
        GoRoute(
          path: RouteNames.more,
          builder: (context, state) => const NavigationDestinationScreen(
            title: 'Más',
            links: [
              NavigationLink(
                label: 'Reservas',
                location: RouteNames.reservations,
                icon: Icons.bookmark_border,
              ),
              NavigationLink(
                label: 'Conteos',
                location: RouteNames.counts,
                icon: Icons.fact_check_outlined,
              ),
              NavigationLink(
                label: 'Categorías',
                location: RouteNames.categories,
                icon: Icons.category_outlined,
              ),
              NavigationLink(
                label: 'Organizaciones',
                location: RouteNames.organizations,
                icon: Icons.account_tree_outlined,
              ),
              NavigationLink(
                label: 'Solicitudes',
                location: RouteNames.requests,
                icon: Icons.inbox_outlined,
              ),
              NavigationLink(
                label: 'Perfil',
                location: RouteNames.profile,
                icon: Icons.person_outline,
              ),
              NavigationLink(
                label: 'Cambiar contraseña',
                location: changePassword,
                icon: Icons.lock_outline,
              ),
            ],
          ),
        ),
      ],
    ),
    GoRoute(
      path: signIn,
      pageBuilder: (context, state) => _authEntryPage(
        state: state,
        child: SignInScreen(controller: controller),
      ),
    ),
    GoRoute(
      path: register,
      pageBuilder: (context, state) => _authEntryPage(
        state: state,
        child: RegisterScreen(controller: controller),
      ),
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

CustomTransitionPage<void> _authEntryPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;

      final transition = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0.025, 0),
        end: Offset.zero,
      ).animate(transition);

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
