import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class UpdateTenantUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  UpdateTenantUseCase(this.tenantRepositoryPort);

  Future<Tenant> execute({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  }) {
    return tenantRepositoryPort.updateTenant(tenantId: tenantId, name: name, description: description, token: token);
  }
}
