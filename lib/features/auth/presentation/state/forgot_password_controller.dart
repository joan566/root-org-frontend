
import 'package:savings_api_frontend/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/verify_code_use_case.dart';

class ForgotPasswordController {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordController({
    required this.forgotPasswordUseCase,
    required this.verifyCodeUseCase,
    required this.resetPasswordUseCase,
  });

  Future<void> sendCode(String email) async {
    await forgotPasswordUseCase.execute(email);
  }

  Future<String> verifyCode(String email, String code) async {
    return await verifyCodeUseCase.execute(email, code);
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await resetPasswordUseCase.execute(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
