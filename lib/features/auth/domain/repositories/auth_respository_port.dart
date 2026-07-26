
import 'package:savings_api_frontend/features/auth/domain/entities/login_sesion.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/register_user.dart';

abstract class AuthRepositoryPort {

  Future<LoginSesion> login({
    required String email,
    required String password,
  });

  Future<RegisterUser> register({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  });

  Future<void> forgotPassword(String email);

  Future<String> verifyCode(String email, String code);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });
}
