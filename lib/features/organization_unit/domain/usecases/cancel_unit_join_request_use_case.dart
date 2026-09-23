import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class CancelUnitJoinRequestUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  CancelUnitJoinRequestUseCase(this.organizationUnitRepositoryPort);

  Future<UnitJoinRequest> execute({required int requestId, required String token}) {
    return organizationUnitRepositoryPort.cancelUnitJoinRequest(requestId: requestId, token: token);
  }
}
