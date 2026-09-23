import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/role_repository_port.dart';

class ListRolesUseCase {
  final RoleRepositoryPort roleRepositoryPort;

  ListRolesUseCase(this.roleRepositoryPort);

  Future<List<Role>> execute({required int tenantId, required String token}) {
    return roleRepositoryPort.listRoles(tenantId: tenantId, token: token);
  }
}
