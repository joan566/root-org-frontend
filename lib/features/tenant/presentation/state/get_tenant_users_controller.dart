import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_tenant_users_use_case.dart';

class GetTenantUsersController {
  final GetTenantUsersUseCase getTenantUsersUseCase;

  GetTenantUsersController(this.getTenantUsersUseCase);

  Future<List<TenantMember>> getTenantUsers(int tenantId, String token) {
    return getTenantUsersUseCase.execute(tenantId: tenantId, token: token);
  }
}
