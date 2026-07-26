import 'package:savings_api_frontend/features/auth/data/mappers/user_tenant_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/tenant_mapper.dart';

import '../../domain/entities/register_tenant_with_owner.dart';
import '../models/register_tenant_with_owner_model.dart';

class RegisterTenantWithOwnerMapper {
  static RegisterTenantWithOwner toDomain(RegisterTenantWithOwnerModel model) {
    return RegisterTenantWithOwner(
        successfully: model.successfully,
        message: model.message,
        tenant: TenantMapper.toDomain(model.tenant),
        userTenant: UserTenantMapper.toDomain(model.userTenant));
  }
}