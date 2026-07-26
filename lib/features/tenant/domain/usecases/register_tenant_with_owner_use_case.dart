import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class RegisterTenantWithOwnerUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  RegisterTenantWithOwnerUseCase(this.tenantRepositoryPort);

  Future<RegisterTenantWithOwner> execute({
    required String name,
    required String description,
    required int userId,
    required String token
  }) {
    return tenantRepositoryPort.registerTenantWithOwner(
        name: name, description: description, userId: userId, token: token);
  }
}