import 'package:dio/dio.dart';

import '../../../../../core/network/interceptors/auth_interceptor.dart';
import '../../../../../core/network/interceptors/token_refresh_interceptor.dart';
import '../../models/app_user_model.dart';
import '../../models/auth_operation_response_model.dart';
import '../../models/auth_request_models.dart';
import '../../models/auth_token_response_model.dart';
import '../../models/login_response_model.dart';

final class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponseModel> signIn(LoginRequestModel request) async {
    final response = await _dio.post<Object?>(
      '/api/v1/auth/login',
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<void> register(RegisterRequestModel request) async {
    await _postOperation('/api/v1/auth/register', request.toJson());
  }

  Future<void> sendEmailVerificationCode(EmailRequestModel request) async {
    await _postOperation(
      '/api/v1/auth/email/verification/send',
      request.toJson(),
    );
  }

  Future<void> confirmEmailVerification(
    ConfirmEmailRequestModel request,
  ) async {
    await _postOperation(
      '/api/v1/auth/email/verification/confirm',
      request.toJson(),
    );
  }

  Future<AuthTokenResponseModel> refresh(
    RefreshTokenRequestModel request,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/v1/auth/refresh',
      data: request.toJson(),
    );
    return AuthTokenResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<AppUserModel> getCurrentUser() async {
    final response = await _dio.get<Object?>(
      '/api/v1/users/me',
      options: _authenticatedOptions,
    );
    final json = _asJsonMap(response.data);
    if (json['successfully'] != true || json['profileInfo'] is! Map) {
      throw const FormatException('Invalid current-user response.');
    }
    return AppUserModel.fromJson(
      Map<String, dynamic>.from(json['profileInfo'] as Map),
    );
  }

  Future<void> signOut({
    required RefreshTokenRequestModel request,
    required String accessToken,
  }) async {
    await _postOperation(
      '/api/v1/auth/logout',
      request.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        extra: {
          AuthInterceptor.requiresAuthExtraKey: true,
          TokenRefreshInterceptor.skipRefreshExtraKey: true,
        },
      ),
    );
  }

  Future<void> requestPasswordReset(EmailRequestModel request) async {
    await _postOperation('/api/v1/auth/password/forgot', request.toJson());
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    await _postOperation('/api/v1/auth/password/reset', request.toJson());
  }

  Future<void> changePassword(ChangePasswordRequestModel request) async {
    await _postOperation(
      '/api/v1/auth/password/change',
      request.toJson(),
      options: _authenticatedOptions,
    );
  }

  Future<void> _postOperation(
    String path,
    Map<String, dynamic> data, {
    Options? options,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: data,
      options: options,
    );
    AuthOperationResponseModel.fromJson(_asJsonMap(response.data));
  }

  Options get _authenticatedOptions =>
      Options(extra: {AuthInterceptor.requiresAuthExtraKey: true});
}

Map<String, dynamic> _asJsonMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('The API returned an invalid response.');
}
