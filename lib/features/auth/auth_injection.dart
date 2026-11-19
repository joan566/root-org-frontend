import 'package:dio/dio.dart';

import '../../core/security/secure_storage.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/manage_password.dart';
import 'domain/usecases/manage_session.dart';
import 'domain/usecases/register_user.dart';
import 'domain/usecases/restore_session.dart';
import 'domain/usecases/sign_in.dart';
import 'domain/usecases/verify_email.dart';
import 'presentation/state/auth_controller.dart';

abstract final class AuthInjection {
  static AuthController create({
    required Dio dio,
    required SecureStorage secureStorage,
  }) {
    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(dio),
      localDataSource: AuthLocalDataSource(secureStorage),
    );

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
}
