
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class VerifyCodeUseCase {
  final AuthRepositoryPort repository;

  VerifyCodeUseCase(this.repository);

  Future<String> execute(String email, String code) {
    return repository.verifyCode(email, code);
  }
}
