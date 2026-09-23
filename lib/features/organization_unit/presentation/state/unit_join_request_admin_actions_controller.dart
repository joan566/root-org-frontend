import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/unit_join_request_admin_actions_use_case.dart';

class UnitJoinRequestAdminActionsController {
  final UnitJoinRequestAdminActionsUseCase unitJoinRequestAdminActionsUseCase;

  UnitJoinRequestAdminActionsController(this.unitJoinRequestAdminActionsUseCase);

  Future<({UnitJoinRequest request, OrganizationUnitMember member})> approve(int id, int requestId, int tenantId, String token) {
    return unitJoinRequestAdminActionsUseCase.approve(id: id, requestId: requestId, tenantId: tenantId, token: token);
  }

  Future<UnitJoinRequest> reject(int id, int requestId, int tenantId, String token) {
    return unitJoinRequestAdminActionsUseCase.reject(id: id, requestId: requestId, tenantId: tenantId, token: token);
  }
}
