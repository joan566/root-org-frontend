import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String? phoneNumber,
    required String password,
  });

  Future<void> sendEmailVerificationCode(String email);

  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  });

  Future<AuthSession?> restoreSession();

  Future<bool> refreshSession({String? accessTokenUsed});

  Future<bool> ensureValidAccessToken();

  Future<void> signOut();

  Future<void> clearLocalSession();

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
