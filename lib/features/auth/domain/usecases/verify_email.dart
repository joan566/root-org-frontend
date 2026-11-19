import '../repositories/auth_repository.dart';

final class SendEmailVerificationCode {
  const SendEmailVerificationCode(this._repository);

  final AuthRepository _repository;

  Future<void> execute(String email) {
    return _repository.sendEmailVerificationCode(email);
  }
}

final class ConfirmEmailVerification {
  const ConfirmEmailVerification(this._repository);

  final AuthRepository _repository;

  Future<void> execute({required String email, required String code}) {
    return _repository.confirmEmailVerification(email: email, code: code);
  }
}
