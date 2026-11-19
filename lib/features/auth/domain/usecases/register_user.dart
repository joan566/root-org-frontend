import '../repositories/auth_repository.dart';

final class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<void> execute({
    required String name,
    required String email,
    required String? phoneNumber,
    required String password,
  }) {
    return _repository.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
