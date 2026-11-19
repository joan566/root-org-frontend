import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> execute() => _repository.restoreSession();
}
