import 'package:savings_api_frontend/features/user/domain/entities/get_user.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/get_user_use_case.dart';

class GetUserController {
  final GetUserUseCase getUserUseCase;

  GetUserController(this.getUserUseCase);

  Future<GetUser> getUser(int userId, String token) async {
    return await getUserUseCase.execute(userId: userId, token: token);
  }
}