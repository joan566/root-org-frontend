import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/list_roles_use_case.dart';

class ListRolesController {
  final ListRolesUseCase listRolesUseCase;

  ListRolesController(this.listRolesUseCase);

  Future<List<Role>> execute(int tenantId, String token) {
    return listRolesUseCase.execute(tenantId: tenantId, token: token);
  }
}
