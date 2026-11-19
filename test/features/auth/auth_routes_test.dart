import 'package:RootOrg/core/routing/app_router.dart';
import 'package:RootOrg/features/auth/domain/entities/auth_session.dart';
import 'package:RootOrg/features/auth/domain/repositories/auth_repository.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_password.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/register_user.dart';
import 'package:RootOrg/features/auth/domain/usecases/restore_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/sign_in.dart';
import 'package:RootOrg/features/auth/domain/usecases/verify_email.dart';
import 'package:RootOrg/features/auth/presentation/routes/auth_routes.dart';
import 'package:RootOrg/features/auth/presentation/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login route adapts to mobile and desktop widths', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.router));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpAndSettle();
    expect(
      find.text('Gestiona tu negocio desde un solo lugar.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset-password deep link accepts and scrubs its token', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = _createController();
    addTearDown(controller.dispose);
    await controller.restore();

    final router = _createRouter(controller);
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.router));
    await tester.pumpAndSettle();
    router.router.go('/auth/reset-password?resetToken=one-time-token');
    await tester.pumpAndSettle();

    expect(find.text('Nueva contraseña'), findsOneWidget);
    expect(
      router.router.routerDelegate.currentConfiguration.uri.queryParameters
          .containsKey('resetToken'),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}

AppRouter _createRouter(AuthController controller) {
  return AppRouter(
    routes: AuthRoutes.build(controller),
    refreshListenable: controller,
    redirect: controller.redirect,
  );
}

AuthController _createController() {
  final repository = _FakeAuthRepository();
  return AuthController(
    signIn: SignIn(repository),
    registerUser: RegisterUser(repository),
    sendEmailVerificationCode: SendEmailVerificationCode(repository),
    confirmEmailVerification: ConfirmEmailVerification(repository),
    restoreSession: RestoreSession(repository),
    refreshSession: RefreshSession(repository),
    ensureValidAccessToken: EnsureValidAccessToken(repository),
    signOut: SignOut(repository),
    clearLocalSession: ClearLocalSession(repository),
    requestPasswordReset: RequestPasswordReset(repository),
    resetPassword: ResetPassword(repository),
    changePassword: ChangePassword(repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> register({
    required String name,
    required String email,
    required String? phoneNumber,
    required String password,
  }) async {}

  @override
  Future<void> sendEmailVerificationCode(String email) async {}

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {}

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<bool> refreshSession({String? accessTokenUsed}) async => true;

  @override
  Future<bool> ensureValidAccessToken() async => false;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> clearLocalSession() async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {}

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {}
}
