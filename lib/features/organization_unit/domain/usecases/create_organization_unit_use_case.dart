import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Siempre crea unidades raíz (`parentUnitId: null`) -- esta iteración no
/// expone jerarquía/anidación en la UI, ver ADR del plan de Estructura.
class CreateOrganizationUnitUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  CreateOrganizationUnitUseCase(this.organizationUnitRepositoryPort);

  Future<OrganizationUnit> execute({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  }) {
    return organizationUnitRepositoryPort.createUnit(
      tenantId: tenantId,
      name: name,
      description: description,
      parentUnitId: null,
      token: token,
    );
  }
}
