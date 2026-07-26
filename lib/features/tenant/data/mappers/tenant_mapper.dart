import 'package:savings_api_frontend/features/tenant/data/models/tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';

class TenantMapper {
  static Tenant toDomain(TenantModel model) {
    return Tenant(
        id: model.id,
        name: model.name,
        description: model.description,
        code: model.code
    );
  }
}