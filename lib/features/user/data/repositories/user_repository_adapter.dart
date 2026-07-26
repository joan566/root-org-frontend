
import 'package:savings_api_frontend/features/user/data/datasources/user_api.dart';
import 'package:savings_api_frontend/features/user/data/mappers/change_password_mapper.dart';
import 'package:savings_api_frontend/features/user/data/mappers/get_user_mapper.dart';
import 'package:savings_api_frontend/features/user/data/mappers/update_profile_mapper.dart';
import 'package:savings_api_frontend/features/user/data/models/change_password_model.dart';
import 'package:savings_api_frontend/features/user/data/models/get_user_model.dart';
import 'package:savings_api_frontend/features/user/data/models/update_profile_model.dart';
import 'package:savings_api_frontend/features/user/domain/entities/change_password.dart';
import 'package:savings_api_frontend/features/user/domain/entities/get_user.dart';
import 'package:savings_api_frontend/features/user/domain/entities/update_profile.dart';
import 'package:savings_api_frontend/features/user/domain/repositories/user_repository_port.dart';

class UserRepositoryAdapter implements UserRepositoryPort {
  final UserApi userApi;

  UserRepositoryAdapter(this.userApi);

  @override
  Future<GetUser> getUser({required int userId, required String token}) async {
    final json = await userApi.getProfile(userId: userId, token: token);

    final model = GetUserModel.fromJson( json);
    return GetUserMapper.toDomain(model);
  }

  @override
  Future<UpdateProfile> updateProfile({
    required int userId,
    required String name,
    required String lastName,
    required String document,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
    required String token
  }) async {
    String birthDate = "${dateOfBirth.year.toString().padLeft(4, '0')}-"
        "${dateOfBirth.month.toString().padLeft(2, '0')}-"
        "${dateOfBirth.day.toString().padLeft(2, '0')}";

    final json = await userApi.updateProfile(
        userId: userId, name: name, lastName: lastName,
        document: document, phoneNumber: phoneNumber,
        dateOfBirth: birthDate,
        gender: gender, token: token
    );

    final model = UpdateProfileModel.fromJson(json);
    return UpdateProfileMapper.toDomain(model);
  }

  @override
  Future<ChangePassword> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token
  }) async {
    final json = await userApi.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        token: token
    );

    final model = ChangePasswordModel.fromJson(json);
    return ChangePasswordMapper.toDomain(model);
  }

}