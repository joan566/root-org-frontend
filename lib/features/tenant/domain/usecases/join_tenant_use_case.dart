import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class JoinTenantUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  JoinTenantUseCase(this.tenantRepositoryPort);

  Future<({JoinRequest request, String message})> execute({
      required String tenantCode,
      required String token
  }) {
    return tenantRepositoryPort.requestToJoinTenant(
        tenantCode: tenantCode,
        token: token
    );
  }
}
