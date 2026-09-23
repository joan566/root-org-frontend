import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/update_tenant_use_case.dart';

class UpdateTenantController {
  final UpdateTenantUseCase updateTenantUseCase;

  UpdateTenantController(this.updateTenantUseCase);

  Future<Tenant> updateTenant(int tenantId, String name, String description, String token) {
    return updateTenantUseCase.execute(tenantId: tenantId, name: name, description: description, token: token);
  }
}
