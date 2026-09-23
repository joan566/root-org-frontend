import 'package:savings_api_frontend/features/organization_unit/domain/usecases/delete_organization_unit_use_case.dart';

class DeleteOrganizationUnitController {
  final DeleteOrganizationUnitUseCase deleteOrganizationUnitUseCase;

  DeleteOrganizationUnitController(this.deleteOrganizationUnitUseCase);

  Future<void> delete(int id, int tenantId, String token) {
    return deleteOrganizationUnitUseCase.execute(id: id, tenantId: tenantId, token: token);
  }
}
