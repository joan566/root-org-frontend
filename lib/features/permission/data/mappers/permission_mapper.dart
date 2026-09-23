import 'package:savings_api_frontend/features/permission/data/models/permission_model.dart';
import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';

class PermissionMapper {
  const PermissionMapper._();

  static Permission toDomain(PermissionModel model) {
    return Permission(
      id: model.id,
      module: model.module,
      code: model.code,
      name: model.name,
      description: model.description,
      active: model.active,
      defaultForMember: model.defaultForMember,
    );
  }
}
