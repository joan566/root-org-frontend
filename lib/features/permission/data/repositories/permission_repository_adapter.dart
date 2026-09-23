import 'package:savings_api_frontend/features/permission/data/datasources/permission_api.dart';
import 'package:savings_api_frontend/features/permission/data/mappers/permission_mapper.dart';
import 'package:savings_api_frontend/features/permission/data/models/permission_model.dart';
import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';
import 'package:savings_api_frontend/features/permission/domain/repositories/permission_repository_port.dart';

class PermissionRepositoryAdapter implements PermissionRepositoryPort {
  final PermissionApi permissionApi;

  PermissionRepositoryAdapter(this.permissionApi);

  @override
  Future<List<Permission>> getMyPermissions({
    required int tenantId,
    int? organizationUnitId,
    required String token,
  }) async {
    final json = await permissionApi.getMyPermissions(
      tenantId: tenantId,
      organizationUnitId: organizationUnitId,
      token: token,
    );
    final permissions = json['permissions'] as List<dynamic>? ?? [];
    return permissions.map((p) => PermissionMapper.toDomain(PermissionModel.fromJson(p))).toList();
  }
}
