
import 'package:savings_api_frontend/features/auth/domain/entities/register_user.dart';
import 'package:savings_api_frontend/features/auth/domain/repositories/auth_respository_port.dart';

class RegisterUserUseCase {
  final AuthRepositoryPort authRepositoryPort;

  RegisterUserUseCase(this.authRepositoryPort);

  Future<RegisterUser> execute({
    required String name,
    required String phoneNumber,
    required String email,
    required String password}) {

    return authRepositoryPort.register(name: name, phoneNumber: phoneNumber,
        email: email, password: password);
  }
}