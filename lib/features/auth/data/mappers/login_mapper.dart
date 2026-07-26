import 'package:savings_api_frontend/features/auth/data/mappers/user_mapper.dart';
import 'package:savings_api_frontend/features/auth/data/models/login_response_model.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/login_sesion.dart';

class LoginMapper {
  static LoginSesion toDomain(LoginResponseModel model) {
    return LoginSesion(
      token: model.token,
      hasTenant: model.hasTenant,
      user: UserMapper.toDomain(model.user),
    );
  }
}