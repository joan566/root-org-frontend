import 'package:dio/dio.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/auth_request_models.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.signIn(
      LoginRequestModel(email: email.trim(), password: password),
    );
    final tokens = response.tokens.toEntity();
    await _localDataSource.saveTokens(tokens);
    return AuthMapper.toSession(response);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String? phoneNumber,
    required String password,
  }) {
    return _remoteDataSource.register(
      RegisterRequestModel(
        name: name.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber?.trim().isEmpty == true
            ? null
            : phoneNumber?.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<void> sendEmailVerificationCode(String email) {
    return _remoteDataSource.sendEmailVerificationCode(
      EmailRequestModel(email.trim()),
    );
  }

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) {
    return _remoteDataSource.confirmEmailVerification(
      ConfirmEmailRequestModel(email: email.trim(), code: code.trim()),
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final tokens = await _localDataSource.readTokens();
    if (tokens == null) return null;

    try {
      final user = await _remoteDataSource.getCurrentUser();
      return AuthMapper.toRestoredSession(
        user: user,
        hasOrganizationUnit: user.organizationUnitMemberships.isNotEmpty,
        tokens: (await _localDataSource.readTokens()) ?? tokens,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _localDataSource.clearTokens();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<bool> refreshSession({String? accessTokenUsed}) async {
    final currentTokens = await _localDataSource.readTokens();
    if (currentTokens == null) {
      return false;
    }
    if (accessTokenUsed != null &&
        currentTokens.accessToken != accessTokenUsed) {
      return true;
    }

    try {
      final tokenResponse = await _remoteDataSource.refresh(
        RefreshTokenRequestModel(currentTokens.refreshToken),
      );
      await _localDataSource.saveTokens(tokenResponse.toEntity());
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        await _localDataSource.clearTokens();
      }
      rethrow;
    }
  }

  @override
  Future<bool> ensureValidAccessToken() async {
    final tokens = await _localDataSource.readTokens();
    if (tokens == null) return false;
    if (tokens.accessTokenExpiresAt.isAfter(
      DateTime.now().add(const Duration(seconds: 30)),
    )) {
      return true;
    }

    try {
      return await refreshSession();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final valid = await ensureValidAccessToken();
      final tokens = await _localDataSource.readTokens();
      if (valid && tokens != null) {
        await _remoteDataSource.signOut(
          request: RefreshTokenRequestModel(tokens.refreshToken),
          accessToken: tokens.accessToken,
        );
      }
    } finally {
      await _localDataSource.clearTokens();
    }
  }

  @override
  Future<void> clearLocalSession() => _localDataSource.clearTokens();

  @override
  Future<void> requestPasswordReset(String email) {
    return _remoteDataSource.requestPasswordReset(
      EmailRequestModel(email.trim()),
    );
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remoteDataSource.resetPassword(
      ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remoteDataSource.changePassword(
      ChangePasswordRequestModel(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
  }
}
