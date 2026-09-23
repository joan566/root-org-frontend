import 'package:savings_api_frontend/features/permission/data/datasources/permission_api.dart';
import 'package:savings_api_frontend/features/permission/data/repositories/permission_repository_adapter.dart';
import 'package:savings_api_frontend/features/permission/domain/usecases/get_my_permissions_use_case.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/get_my_permissions_controller.dart';

class PermissionInjection {
  static GetMyPermissionsController getMyPermissionsController() {
    final api = PermissionApi();
    final repository = PermissionRepositoryAdapter(api);
    final useCase = GetMyPermissionsUseCase(repository);

    return GetMyPermissionsController(useCase);
  }
}
