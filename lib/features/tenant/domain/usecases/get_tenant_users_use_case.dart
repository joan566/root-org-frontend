import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class GetTenantUsersUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  GetTenantUsersUseCase(this.tenantRepositoryPort);

  Future<List<TenantMember>> execute({required int tenantId, required String token}) {
    return tenantRepositoryPort.getTenantUsers(tenantId: tenantId, token: token);
  }
}
