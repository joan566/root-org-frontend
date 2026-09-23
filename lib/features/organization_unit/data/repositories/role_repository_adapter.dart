import 'package:savings_api_frontend/features/organization_unit/data/datasources/role_api.dart';
import 'package:savings_api_frontend/features/organization_unit/data/mappers/role_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/role_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/role_repository_port.dart';

class RoleRepositoryAdapter implements RoleRepositoryPort {
  final RoleApi roleApi;

  RoleRepositoryAdapter(this.roleApi);

  @override
  Future<List<Role>> listRoles({required int tenantId, required String token}) async {
    final json = await roleApi.listRoles(tenantId: tenantId, token: token);
    final roles = json['roles'] as List<dynamic>? ?? [];
    return roles.map((r) => RoleMapper.toDomain(RoleModel.fromJson(r))).toList();
  }
}
