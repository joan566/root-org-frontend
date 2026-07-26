import 'package:savings_api_frontend/features/auth/data/mappers/user_tenant_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/models/join_tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/join_tenant.dart';

class JoinTenantMapper {
  static JoinTenant toDomain(JoinTenantModel model) {
    return JoinTenant(
        successfully: model.successfully,
        message: model.message,
        userTenant: UserTenantMapper.toDomain(model.userTenant));
  }
}