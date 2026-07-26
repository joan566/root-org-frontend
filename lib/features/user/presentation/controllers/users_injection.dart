import 'package:savings_api_frontend/features/user/data/datasources/user_api.dart';
import 'package:savings_api_frontend/features/user/data/repositories/user_repository_adapter.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/change_password_use_case.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/get_user_use_case.dart';
import 'package:savings_api_frontend/features/user/domain/usecases/update_profile_use_case.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/change_password_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/get_user_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/update_profile_controller.dart';

class UsersInjection {
  static GetUserController getUserController() {
    final userApi = UserApi();
    final repository = UserRepositoryAdapter(userApi);
    final useCase = GetUserUseCase(repository);

    return GetUserController(useCase);
  }

  static UpdateProfileController updateProfileController() {
    final userApi = UserApi();
    final repository = UserRepositoryAdapter(userApi);
    final useCase = UpdateProfileUseCase(repository);

    return UpdateProfileController(useCase);
  }

  static ChangePasswordController changePasswordController() {
    final userApi = UserApi();
    final repository = UserRepositoryAdapter(userApi);
    final useCase = ChangePasswordUseCase(repository);

    return ChangePasswordController(useCase);
  }
}