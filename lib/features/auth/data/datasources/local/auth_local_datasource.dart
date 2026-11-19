import 'package:RootOrg/core/security/secure_storage.dart';
import 'package:RootOrg/core/storage/storage_keys.dart';
import '../../../domain/entities/auth_tokens.dart';

final class AuthLocalDataSource {
  const AuthLocalDataSource(this._secureStorage);

  final SecureStorage _secureStorage;

  Future<AuthTokens?> readTokens() async {
    final values = await Future.wait([
      _secureStorage.read(StorageKeys.accessToken),
      _secureStorage.read(StorageKeys.refreshToken),
      _secureStorage.read(StorageKeys.accessTokenExpiresAt),
    ]);
    final accessToken = values[0];
    final refreshToken = values[1];
    final expiresAtValue = values[2];

    if (accessToken == null && refreshToken == null && expiresAtValue == null) {
      return null;
    }

    final expiresAt = expiresAtValue == null
        ? null
        : DateTime.tryParse(expiresAtValue);
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty ||
        expiresAt == null) {
      await clearTokens();
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: expiresAt,
    );
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _secureStorage.write(StorageKeys.accessToken, tokens.accessToken);
      await _secureStorage.write(StorageKeys.refreshToken, tokens.refreshToken);
      await _secureStorage.write(
        StorageKeys.accessTokenExpiresAt,
        tokens.accessTokenExpiresAt.toUtc().toIso8601String(),
      );
    } on Object {
      await clearTokens();
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(StorageKeys.accessToken),
      _secureStorage.delete(StorageKeys.refreshToken),
      _secureStorage.delete(StorageKeys.accessTokenExpiresAt),
    ]);
  }
}
