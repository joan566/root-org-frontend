import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class GetOrganizationUnitsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  GetOrganizationUnitsUseCase(this.organizationUnitRepositoryPort);

  Future<List<OrganizationUnit>> execute({required int tenantId, required String token}) {
    return organizationUnitRepositoryPort.getUnits(tenantId: tenantId, token: token);
  }
}
