import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
