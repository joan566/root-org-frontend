import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';
import 'package:savings_api_frontend/features/permission/domain/repositories/permission_repository_port.dart';

class GetMyPermissionsUseCase {
  final PermissionRepositoryPort permissionRepositoryPort;

  GetMyPermissionsUseCase(this.permissionRepositoryPort);

  Future<List<Permission>> execute({
    required int tenantId,
    int? organizationUnitId,
    required String token,
  }) {
    return permissionRepositoryPort.getMyPermissions(
      tenantId: tenantId,
      organizationUnitId: organizationUnitId,
      token: token,
    );
  }
}
