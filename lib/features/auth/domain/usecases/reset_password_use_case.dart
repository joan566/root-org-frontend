
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class ResetPasswordUseCase {
  final AuthRepositoryPort repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
