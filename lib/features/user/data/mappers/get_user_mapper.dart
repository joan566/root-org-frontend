import 'package:savings_api_frontend/features/user/data/models/get_user_model.dart';
import 'package:savings_api_frontend/features/user/domain/entities/get_user.dart';

import '../../../auth/data/mappers/user_mapper.dart';

class GetUserMapper {
  static GetUser toDomain(GetUserModel model) {
    return GetUser(
        successfully: model.successfully,
        message: model.message,
        user: UserMapper.toDomain(model.user)
    );
  }
}