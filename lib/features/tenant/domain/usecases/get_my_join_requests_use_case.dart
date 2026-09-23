import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

class GetMyJoinRequestsUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  GetMyJoinRequestsUseCase(this.tenantRepositoryPort);

  Future<List<JoinRequest>> execute({required String token}) {
    return tenantRepositoryPort.getMyJoinRequests(token: token);
  }
}
