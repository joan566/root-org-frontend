import 'package:savings_api_frontend/features/user/domain/entities/update_profile.dart';

import '../repositories/user_repository_port.dart';

class UpdateProfileUseCase {
  final UserRepositoryPort userRepositoryPort;

  UpdateProfileUseCase(this.userRepositoryPort);

  Future<UpdateProfile> execute({
    required int userId,
    required String name,
    required String lastName,
    required String document,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
    required String token
  }) {
    return userRepositoryPort.updateProfile(
        userId: userId, name: name, lastName: lastName,
        document: document, phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth, gender: gender, token: token
    );
  }
}