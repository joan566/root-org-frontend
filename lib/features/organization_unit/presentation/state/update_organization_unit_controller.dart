import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/update_organization_unit_use_case.dart';

class UpdateOrganizationUnitController {
  final UpdateOrganizationUnitUseCase updateOrganizationUnitUseCase;

  UpdateOrganizationUnitController(this.updateOrganizationUnitUseCase);

  Future<OrganizationUnit> update({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    required int? parentUnitId,
    String? status,
    required String token,
  }) {
    return updateOrganizationUnitUseCase.execute(
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
