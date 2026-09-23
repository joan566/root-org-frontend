import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class GetUnitJoinRequestsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  GetUnitJoinRequestsUseCase(this.organizationUnitRepositoryPort);

  Future<List<UnitJoinRequest>> execute({required int id, required int tenantId, required String token}) {
    return organizationUnitRepositoryPort.getUnitJoinRequests(id: id, tenantId: tenantId, token: token);
  }
}
