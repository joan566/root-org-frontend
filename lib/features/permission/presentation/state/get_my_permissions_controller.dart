import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';
import 'package:savings_api_frontend/features/permission/domain/usecases/get_my_permissions_use_case.dart';

class GetMyPermissionsController {
  final GetMyPermissionsUseCase getMyPermissionsUseCase;

  GetMyPermissionsController(this.getMyPermissionsUseCase);

  Future<List<Permission>> execute(int tenantId, String token, {int? organizationUnitId}) {
    return getMyPermissionsUseCase.execute(tenantId: tenantId, organizationUnitId: organizationUnitId, token: token);
  }
}
