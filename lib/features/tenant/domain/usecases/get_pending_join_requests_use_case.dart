import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class GetPendingJoinRequestsUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  GetPendingJoinRequestsUseCase(this.tenantRepositoryPort);

  Future<List<JoinRequest>> execute({required int tenantId, required String token}) {
    return tenantRepositoryPort.getPendingJoinRequests(tenantId: tenantId, token: token);
  }
}
