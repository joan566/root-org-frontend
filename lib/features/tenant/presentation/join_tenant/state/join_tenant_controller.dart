import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_tenant_use_case.dart';

class JoinTenantController {
  final JoinTenantUseCase joinTenantUseCase;

  JoinTenantController(this.joinTenantUseCase);

  Future<({JoinRequest request, String message})> joinTenant(String tenantCode, String token) async {
    return await joinTenantUseCase.execute(tenantCode: tenantCode, token: token);
  }
}
