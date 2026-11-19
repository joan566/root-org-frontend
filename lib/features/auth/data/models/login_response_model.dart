import '../../domain/entities/auth_session.dart';
import 'app_user_model.dart';
import 'auth_response_exception.dart';
import 'auth_token_response_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.tokens,
    required this.hasOrganizationUnit,
    required this.user,
  });

  final AuthTokenResponseModel tokens;
  final bool hasOrganizationUnit;
  final AppUserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final hasOrganizationUnit = json['hasOrganizationUnit'];
    final userJson = json['user'];
    if (hasOrganizationUnit is! bool || userJson is! Map) {
      throw const AuthResponseException();
    }

    return LoginResponseModel(
      tokens: AuthTokenResponseModel.fromJson(json),
      hasOrganizationUnit: hasOrganizationUnit,
      user: AppUserModel.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }

  AuthSession toEntity({DateTime? now}) {
    return AuthSession(
      user: user.toEntity(),
      hasOrganizationUnit: hasOrganizationUnit,
      accessTokenExpiresAt: tokens.toEntity(now: now).accessTokenExpiresAt,
    );
  }
}
