import 'package:savings_api_frontend/features/user/data/models/change_password_model.dart';
import 'package:savings_api_frontend/features/user/domain/entities/change_password.dart';

class ChangePasswordMapper {
  static ChangePassword toDomain(ChangePasswordModel model) {
    return ChangePassword(
        successfully: model.successfully,
        message: model.message
    );
  }
}