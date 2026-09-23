import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/request_to_join_unit_use_case.dart';

class RequestToJoinUnitController {
  final RequestToJoinUnitUseCase requestToJoinUnitUseCase;

  RequestToJoinUnitController(this.requestToJoinUnitUseCase);

  Future<({UnitJoinRequest request, String message})> requestToJoin(int unitId, String token) {
    return requestToJoinUnitUseCase.execute(id: unitId, token: token);
  }
}
