import 'package:RootOrg/features/auth/domain/entities/app_user.dart';
import 'package:RootOrg/features/auth/domain/entities/auth_session.dart';
import 'package:RootOrg/features/auth/domain/repositories/auth_repository.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_password.dart';
import 'package:RootOrg/features/auth/domain/usecases/manage_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/register_user.dart';
import 'package:RootOrg/features/auth/domain/usecases/restore_session.dart';
import 'package:RootOrg/features/auth/domain/usecases/sign_in.dart';
import 'package:RootOrg/features/auth/domain/usecases/verify_email.dart';
import 'package:RootOrg/features/auth/presentation/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores a signed-out state when no session exists', () async {
    final controller = _createController(_FakeAuthRepository());
    addTearDown(controller.dispose);

    await controller.restore();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.session, isNull);
  });

  test('moves to authenticated state after login succeeds', () async {
    final repository = _FakeAuthRepository();
    final controller = _createController(repository);
    addTearDown(controller.dispose);

    await controller.signIn(email: 'a@example.com', password: 'Password1');

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.session?.user.id, 12);
  });

  test(
    'clears in-memory authentication even when remote logout fails',
    () async {
      final repository = _FakeAuthRepository()
        ..logoutError = StateError('offline');
      final controller = _createController(repository);
      addTearDown(controller.dispose);
      await controller.signIn(email: 'a@example.com', password: 'Password1');

      await expectLater(controller.signOut(), throwsStateError);

      expect(controller.status, AuthStatus.unauthenticated);
      expect(controller.session, isNull);
    },
  );
}

AuthController _createController(AuthRepository repository) {
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
  Object? logoutError;
  final session = AuthSession(
    user: const AppUser(id: 12, name: 'Test', organizationUnitMemberships: []),
    hasOrganizationUnit: false,
    accessTokenExpiresAt: DateTime.utc(2027),
  );

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async => session;

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
  Future<bool> ensureValidAccessToken() async => true;

  @override
  Future<void> signOut() async {
    if (logoutError != null) throw logoutError!;
  }

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
