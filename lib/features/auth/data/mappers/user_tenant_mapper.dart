
import 'package:savings_api_frontend/features/auth/data/models/user_tenant_model.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/tenant_mapper.dart';

class UserTenantMapper {
  static UserTenant toDomain(UserTenantModel model) {
    return UserTenant(
      id: model.id,
      tenant: TenantMapper.toDomain(model.tenant),
      userId: model.userId,
      roles: model.roles,
      status: model.status,
    );
  }
}