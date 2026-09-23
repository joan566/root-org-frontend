import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';

abstract class PermissionRepositoryPort {
  Future<List<Permission>> getMyPermissions({
    required int tenantId,
    int? organizationUnitId,
    required String token,
  });
}
