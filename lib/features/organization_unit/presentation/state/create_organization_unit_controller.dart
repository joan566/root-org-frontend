import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/create_organization_unit_use_case.dart';

class CreateOrganizationUnitController {
  final CreateOrganizationUnitUseCase createOrganizationUnitUseCase;

  CreateOrganizationUnitController(this.createOrganizationUnitUseCase);

  Future<OrganizationUnit> create({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  }) {
    return createOrganizationUnitUseCase.execute(tenantId: tenantId, name: name, description: description, token: token);
  }
}
