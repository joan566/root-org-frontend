import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Soft delete -- el backend solo marca `status = INACTIVE`, no borra
/// historial de integrantes ni valida si la unidad tiene miembros activos.
class DeleteOrganizationUnitUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  DeleteOrganizationUnitUseCase(this.organizationUnitRepositoryPort);

  Future<void> execute({required int id, required int tenantId, required String token}) {
    return organizationUnitRepositoryPort.deleteUnit(id: id, tenantId: tenantId, token: token);
  }
}
