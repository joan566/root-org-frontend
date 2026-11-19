import '../../domain/entities/auth_tokens.dart';
import 'auth_response_exception.dart';

class AuthTokenResponseModel {
  const AuthTokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;

  factory AuthTokenResponseModel.fromJson(Map<String, dynamic> json) {
    final accessToken = json['token'];
    final refreshToken = json['refreshToken'];
    final expiresIn = json['expiresIn'];
    if (json['successfully'] != true ||
        accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty ||
        expiresIn is! num ||
        expiresIn < 0) {
      throw const AuthResponseException();
    }

    return AuthTokenResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: expiresIn.toInt(),
    );
  }

  AuthTokens toEntity({DateTime? now}) {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: (now ?? DateTime.now()).add(
        Duration(seconds: expiresInSeconds),
      ),
    );
  }
}
