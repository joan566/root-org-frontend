import 'package:savings_api_frontend/features/user/domain/entities/change_password.dart';
import 'package:savings_api_frontend/features/user/domain/repositories/user_repository_port.dart';

class ChangePasswordUseCase {
  final UserRepositoryPort userRepositoryPort;

  ChangePasswordUseCase(this.userRepositoryPort);

  Future<ChangePassword> execute({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token
  }) {
    return userRepositoryPort.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        token: token
    );
  }
}