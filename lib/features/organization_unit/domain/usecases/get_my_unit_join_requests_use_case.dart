import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class GetMyUnitJoinRequestsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  GetMyUnitJoinRequestsUseCase(this.organizationUnitRepositoryPort);

  Future<List<UnitJoinRequest>> execute({required String token}) {
    return organizationUnitRepositoryPort.getMyUnitJoinRequests(token: token);
  }
}
