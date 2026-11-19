import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/token_refresh_handler.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/manage_password.dart';
import '../../domain/usecases/manage_session.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/verify_email.dart';

enum AuthStatus { restoring, unauthenticated, authenticated, restoreFailed }

final class AuthController extends ChangeNotifier
    implements TokenRefreshHandler {
  AuthController({
    required SignIn signIn,
    required RegisterUser registerUser,
    required SendEmailVerificationCode sendEmailVerificationCode,
    required ConfirmEmailVerification confirmEmailVerification,
    required RestoreSession restoreSession,
    required RefreshSession refreshSession,
    required EnsureValidAccessToken ensureValidAccessToken,
    required SignOut signOut,
    required ClearLocalSession clearLocalSession,
    required RequestPasswordReset requestPasswordReset,
    required ResetPassword resetPassword,
    required ChangePassword changePassword,
  }) : _signIn = signIn,
       _registerUser = registerUser,
       _sendEmailVerificationCode = sendEmailVerificationCode,
       _confirmEmailVerification = confirmEmailVerification,
       _restoreSession = restoreSession,
       _refreshSession = refreshSession,
       _ensureValidAccessToken = ensureValidAccessToken,
       _signOut = signOut,
       _clearLocalSession = clearLocalSession,
       _requestPasswordReset = requestPasswordReset,
       _resetPassword = resetPassword,
       _changePassword = changePassword;

  final SignIn _signIn;
  final RegisterUser _registerUser;
  final SendEmailVerificationCode _sendEmailVerificationCode;
  final ConfirmEmailVerification _confirmEmailVerification;
  final RestoreSession _restoreSession;
  final RefreshSession _refreshSession;
  final EnsureValidAccessToken _ensureValidAccessToken;
  final SignOut _signOut;
  final ClearLocalSession _clearLocalSession;
  final RequestPasswordReset _requestPasswordReset;
  final ResetPassword _resetPassword;
  final ChangePassword _changePassword;

  AuthStatus _status = AuthStatus.restoring;
  AuthSession? _session;
  Object? _restoreError;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  Object? get restoreError => _restoreError;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final isPasswordReset = path == '/auth/reset-password';
    final isPublicRoute =
        path == '/auth/sign-in' ||
        path == '/auth/register' ||
        path == '/auth/email-verification' ||
        path == '/auth/forgot-password' ||
        isPasswordReset;

    if (_status == AuthStatus.restoring) return null;
    if (_status == AuthStatus.restoreFailed) {
      return path == '/' || isPublicRoute ? null : '/';
    }

    if (isAuthenticated) {
      if (isPublicRoute && !isPasswordReset) return '/';
      return null;
    }

    if (!isPublicRoute || path == '/') return '/auth/sign-in';
    return null;
  }

  Future<void> restore() async {
    _status = AuthStatus.restoring;
    _restoreError = null;
    notifyListeners();
    try {
      _session = await _restoreSession.execute();
      _status = _session == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } on Object catch (error) {
      _restoreError = error;
      _status = AuthStatus.restoreFailed;
    }
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final session = await _signIn.execute(email: email, password: password);
    _session = session;
    _status = AuthStatus.authenticated;
    _restoreError = null;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    String? phoneNumber,
    required String password,
  }) {
    return _registerUser.execute(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  Future<void> resendEmailVerificationCode(String email) {
    return _sendEmailVerificationCode.execute(email);
  }

  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) {
    return _confirmEmailVerification.execute(email: email, code: code);
  }

  Future<void> requestPasswordReset(String email) {
    return _requestPasswordReset.execute(email);
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _resetPassword.execute(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _changePassword.execute(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> signOut() async {
    try {
      await _signOut.execute();
    } finally {
      _session = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  @override
  Future<bool> ensureValidAccessToken() {
    return _ensureValidAccessToken.execute();
  }

  @override
  Future<bool> refreshAccessToken({String? accessTokenUsed}) async {
    try {
      final refreshed = await _refreshSession.execute(
        accessTokenUsed: accessTokenUsed?.replaceFirst(
          RegExp(r'^Bearer\s+'),
          '',
        ),
      );
      if (!refreshed) await onSessionExpired();
      return refreshed;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        await onSessionExpired();
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> onSessionExpired() async {
    try {
      await _clearLocalSession.execute();
    } finally {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _restoreError = null;
      notifyListeners();
    }
  }
}
