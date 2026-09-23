import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class GetUnitManagerUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  GetUnitManagerUseCase(this.organizationUnitRepositoryPort);

  Future<UnitManager?> execute({required int id, required int tenantId, required String token}) {
    return organizationUnitRepositoryPort.getManager(id: id, tenantId: tenantId, token: token);
  }
}
