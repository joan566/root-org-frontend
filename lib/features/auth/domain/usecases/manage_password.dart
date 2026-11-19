import '../repositories/auth_repository.dart';

final class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> execute(String email) {
    return _repository.requestPasswordReset(email);
  }
}

final class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<void> execute({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

final class ChangePassword {
  const ChangePassword(this._repository);

  final AuthRepository _repository;

  Future<void> execute({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
