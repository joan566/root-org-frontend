abstract interface class TokenRefreshHandler {
  Future<bool> ensureValidAccessToken();

  Future<bool> refreshAccessToken({String? accessTokenUsed});

  Future<void> onSessionExpired();
}
