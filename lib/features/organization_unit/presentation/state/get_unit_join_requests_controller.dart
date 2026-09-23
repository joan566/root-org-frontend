import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_unit_join_requests_use_case.dart';

class GetUnitJoinRequestsController {
  final GetUnitJoinRequestsUseCase getUnitJoinRequestsUseCase;

  GetUnitJoinRequestsController(this.getUnitJoinRequestsUseCase);

  Future<List<UnitJoinRequest>> getRequests(int id, int tenantId, String token) {
    return getUnitJoinRequestsUseCase.execute(id: id, tenantId: tenantId, token: token);
  }
}
