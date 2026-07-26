import 'package:savings_api_frontend/features/user/domain/entities/update_profile.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/update_profile_use_case.dart';

class UpdateProfileController {
  final UpdateProfileUseCase updateProfileUseCase;

  UpdateProfileController(this.updateProfileUseCase);

  Future<UpdateProfile> updateProfile(
    int userId,
    String name,
    String lastName,
    String document,
    String phoneNumber,
    DateTime dateOfBirth,
    String gender,
    String token
  ) async {
    return await updateProfileUseCase.execute(
        userId: userId, name: name, lastName: lastName,
        document: document, phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth, gender: gender, token: token
    );
  }
}