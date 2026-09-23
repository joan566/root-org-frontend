import 'package:savings_api_frontend/features/organization_unit/domain/usecases/organization_unit_manager_actions_use_case.dart';

class OrganizationUnitManagerActionsController {
  final OrganizationUnitManagerActionsUseCase organizationUnitManagerActionsUseCase;

  OrganizationUnitManagerActionsController(this.organizationUnitManagerActionsUseCase);

  Future<void> assign(int id, int tenantId, int userId, int roleId, String token) {
    return organizationUnitManagerActionsUseCase.assign(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  Future<void> transfer(int id, int tenantId, int newUserId, String token) {
    return organizationUnitManagerActionsUseCase.transfer(id: id, tenantId: tenantId, newUserId: newUserId, token: token);
  }

  Future<void> remove(int id, int tenantId, String token) {
    return organizationUnitManagerActionsUseCase.remove(id: id, tenantId: tenantId, token: token);
  }
}
