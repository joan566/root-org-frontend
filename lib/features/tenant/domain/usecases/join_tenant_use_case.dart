import 'package:savings_api_frontend/features/tenant/domain/entities/join_tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class JoinTenantUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  JoinTenantUseCase(this.tenantRepositoryPort);

  Future<JoinTenant> execute({
      required int userId,
      required String tenantCode,
      required String token
  }) {
    return tenantRepositoryPort.joinTenant(
        userId: userId, tenantCode: tenantCode,
        token: token
    );
  }
}