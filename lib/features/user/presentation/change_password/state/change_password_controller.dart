import 'package:savings_api_frontend/features/user/domain/entities/change_password.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/change_password_use_case.dart';

class ChangePasswordController {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordController(this.changePasswordUseCase);

  Future<ChangePassword> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
    String token
  ) async {
    return await changePasswordUseCase.execute(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        token: token
    );
  }
}