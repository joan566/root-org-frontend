
import '../../../domain/entities/login_sesion.dart';
import '../../../domain/usecases/login_user_case.dart';

class LoginController {
  final LoginUserUseCase loginUseCase;

  LoginController(this.loginUseCase);

  Future<LoginSesion> login(String email, String password) async {
    return await loginUseCase.execute(email: email, password: password);
  }
}