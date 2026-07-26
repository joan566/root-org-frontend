
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class ForgotPasswordUseCase {
  final AuthRepositoryPort repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.forgotPassword(email);
  }
}
