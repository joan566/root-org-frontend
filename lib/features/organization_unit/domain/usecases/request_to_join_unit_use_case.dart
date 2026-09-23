import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class RequestToJoinUnitUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  RequestToJoinUnitUseCase(this.organizationUnitRepositoryPort);

  Future<({UnitJoinRequest request, String message})> execute({required int id, required String token}) {
    return organizationUnitRepositoryPort.requestToJoinUnit(id: id, token: token);
  }
}
