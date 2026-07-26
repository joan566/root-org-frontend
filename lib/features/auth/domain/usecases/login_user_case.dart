
import 'package:savings_api_frontend/features/auth/domain/entities/login_sesion.dart';
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class LoginUserUseCase {
  final AuthRepositoryPort authRepositoryPort;

  LoginUserUseCase(this.authRepositoryPort);

  Future<LoginSesion> execute({required String email, required String password}) {
    return authRepositoryPort.login(email: email, password: password);
  }

}