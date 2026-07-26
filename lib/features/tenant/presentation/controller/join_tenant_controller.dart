import 'package:savings_api_frontend/features/tenant/domain/entities/join_tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_tenant_use_case.dart';

class JoinTenantController {
  final JoinTenantUseCase joinTenantUseCase;

  JoinTenantController(this.joinTenantUseCase);

  Future<JoinTenant> joinTenant(
      int userId, String tenantCode,
      String token
    ) async {
    return await joinTenantUseCase.execute(
        userId: userId, tenantCode: tenantCode,
        token: token
    );
  }
}