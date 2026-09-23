import 'package:savings_api_frontend/features/tenant/data/models/tenant_user_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

class TenantUserMapper {
  const TenantUserMapper._();

  static TenantMember toDomain(TenantUserModel model) {
    return TenantMember(
      userId: model.userId,
      name: model.name,
      lastName: model.lastName,
      email: model.email,
      status: model.status,
      roles: model.roles,
    );
  }
}
