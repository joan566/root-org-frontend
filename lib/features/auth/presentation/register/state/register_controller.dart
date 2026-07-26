import 'package:savings_api_frontend/features/auth/domain/entities/register_user.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/register_user_use_case.dart';

class RegisterController {
  final RegisterUserUseCase registerUserUseCase;

  RegisterController(this.registerUserUseCase);

  Future<RegisterUser> register(
      String name, String phoneNumber, String email, String password) async {
    try {
      return await registerUserUseCase.execute(
          name: name,
          phoneNumber: phoneNumber,
          email: email,
          password: password
      );
    } catch (e) {
      // Re-lanzamos el error para que la UI pueda capturarlo y mostrarlo
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}