
import 'package:savings_api_frontend/features/auth/data/models/register_response_model.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/register_user.dart';

class RegisterUserMapper {
  static RegisterUser toDomain(RegisterUserResponseModel model) {
    return RegisterUser(
      successfully: model.successfully,
      message: model.message,
    );
  }
}