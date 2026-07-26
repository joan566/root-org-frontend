import 'package:savings_api_frontend/features/auth/data/mappers/user_mapper.dart';
import 'package:savings_api_frontend/features/user/data/models/update_profile_model.dart';
import 'package:savings_api_frontend/features/user/domain/entities/update_profile.dart';

class UpdateProfileMapper {
  static UpdateProfile toDomain(UpdateProfileModel model) {
    return UpdateProfile(
        successfully: model.successfully,
        message: model.message,
        user: UserMapper.toDomain(model.user)
    );
  }
}