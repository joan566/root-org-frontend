import '../repositories/auth_repository.dart';

final class RefreshSession {
  const RefreshSession(this._repository);

  final AuthRepository _repository;

  Future<bool> execute({String? accessTokenUsed}) {
    return _repository.refreshSession(accessTokenUsed: accessTokenUsed);
  }
}

final class EnsureValidAccessToken {
  const EnsureValidAccessToken(this._repository);

  final AuthRepository _repository;

  Future<bool> execute() => _repository.ensureValidAccessToken();
}

final class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> execute() => _repository.signOut();
}

final class ClearLocalSession {
  const ClearLocalSession(this._repository);

  final AuthRepository _repository;

  Future<void> execute() => _repository.clearLocalSession();
}
