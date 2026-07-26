import 'package:savings_api_frontend/features/user/domain/entities/change_password.dart';
import 'package:savings_api_frontend/features/user/domain/entities/get_user.dart';
import 'package:savings_api_frontend/features/user/domain/entities/update_profile.dart';

abstract class UserRepositoryPort {
  Future<GetUser> getUser({
    required int userId,
    required String token
  });

  Future<UpdateProfile> updateProfile({
    required int userId,
    required String name,
    required String lastName,
    required String document,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
    required String token
  });

  Future<ChangePassword> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token
  });
}