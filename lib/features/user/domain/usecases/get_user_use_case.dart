import 'package:savings_api_frontend/features/user/domain/entities/get_user.dart';
import 'package:savings_api_frontend/features/user/domain/repositories/user_repository_port.dart';

class GetUserUseCase {
  final UserRepositoryPort userRepositoryPort;

  GetUserUseCase(this.userRepositoryPort);

  Future<GetUser> execute({required int userId, required String token}) {
    return userRepositoryPort.getUser(userId: userId, token: token);
  }
}