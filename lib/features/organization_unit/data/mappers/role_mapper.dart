import 'package:savings_api_frontend/features/organization_unit/data/models/role_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';

class RoleMapper {
  const RoleMapper._();

  static Role toDomain(RoleModel model) {
    return Role(
      id: model.id,
      tenantId: model.tenantId,
      name: model.name,
      description: model.description,
      systemRole: model.systemRole,
    );
  }
}
