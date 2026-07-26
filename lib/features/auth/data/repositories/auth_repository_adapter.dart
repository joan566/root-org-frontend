
import 'package:savings_api_frontend/features/auth/data/datasources/auth_api.dart';
import 'package:savings_api_frontend/features/auth/data/mappers/login_mapper.dart';
import 'package:savings_api_frontend/features/auth/data/mappers/register_user_mapper.dart';
import 'package:savings_api_frontend/features/auth/data/models/login_response_model.dart';
import 'package:savings_api_frontend/features/auth/data/models/register_response_model.dart';
import 'package:savings_api_frontend/features/auth/data/models/verify_code_response_model.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/login_sesion.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/register_user.dart';
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class AuthRepositoryAdapter implements AuthRepositoryPort {
  final AuthApi authApi;

  AuthRepositoryAdapter(this.authApi);

  @override
  Future<LoginSesion> login({required String email, required String password}) async {
    final json = await authApi.login(email: email, password: password);

    final model = LoginResponseModel.fromJson(json);
    return LoginMapper.toDomain(model);
  }

  @override
  Future<RegisterUser> register({required String name, required String phoneNumber, 
  required String email, required String password}) async {
    final json = await authApi.register(
      name: name, phoneNumber: phoneNumber, 
      email: email, password: password);

    final model = RegisterUserResponseModel.fromJson(json);
    return RegisterUserMapper.toDomain(model);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await authApi.forgotPassword(email);
  }

  @override
  Future<String> verifyCode(String email, String code) async {
    final json = await authApi.verifyCode(email, code);

    final model = VerifyCodeResponseModel.fromJson(json);
    return model.resetToken;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await authApi.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
