import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_my_unit_join_requests_use_case.dart';

class GetMyUnitJoinRequestsController {
  final GetMyUnitJoinRequestsUseCase getMyUnitJoinRequestsUseCase;

  GetMyUnitJoinRequestsController(this.getMyUnitJoinRequestsUseCase);

  Future<List<UnitJoinRequest>> getMyUnitJoinRequests(String token) {
    return getMyUnitJoinRequestsUseCase.execute(token: token);
  }
}
