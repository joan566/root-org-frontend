import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/organization_unit_member_actions_use_case.dart';

class OrganizationUnitMemberActionsController {
  final OrganizationUnitMemberActionsUseCase organizationUnitMemberActionsUseCase;

  OrganizationUnitMemberActionsController(this.organizationUnitMemberActionsUseCase);

  Future<OrganizationUnitMember> assign(int id, int tenantId, int userId, String token) {
    return organizationUnitMemberActionsUseCase.assign(id: id, tenantId: tenantId, userId: userId, token: token);
  }

  Future<void> remove(int id, int tenantId, int userId, String token) {
    return organizationUnitMemberActionsUseCase.remove(id: id, tenantId: tenantId, userId: userId, token: token);
  }

  Future<void> assignRole(int id, int tenantId, int userId, int roleId, String token) {
    return organizationUnitMemberActionsUseCase.assignRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  Future<void> removeRole(int id, int tenantId, int userId, int roleId, String token) {
    return organizationUnitMemberActionsUseCase.removeRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }
}
