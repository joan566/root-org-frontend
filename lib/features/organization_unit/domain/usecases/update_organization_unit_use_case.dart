import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Cubre tanto editar nombre/descripción como activar/desactivar (vía
/// [status]). [parentUnitId] se recibe explícito (no se fuerza a null) para
/// no re-parentar por accidente una unidad que ya tuviera jerarquía asignada
/// por otro cliente.
class UpdateOrganizationUnitUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  UpdateOrganizationUnitUseCase(this.organizationUnitRepositoryPort);

  Future<OrganizationUnit> execute({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    required int? parentUnitId,
    String? status,
    required String token,
  }) {
    return organizationUnitRepositoryPort.updateUnit(
      id: id,
      tenantId: tenantId,
      name: name,
      description: description,
      parentUnitId: parentUnitId,
      status: status,
      token: token,
    );
  }
}
