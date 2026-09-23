import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';

abstract class RoleRepositoryPort {
  Future<List<Role>> listRoles({required int tenantId, required String token});
}
