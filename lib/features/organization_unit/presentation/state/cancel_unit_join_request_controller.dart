import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/cancel_unit_join_request_use_case.dart';

class CancelUnitJoinRequestController {
  final CancelUnitJoinRequestUseCase cancelUnitJoinRequestUseCase;

  CancelUnitJoinRequestController(this.cancelUnitJoinRequestUseCase);

  Future<UnitJoinRequest> cancel(int requestId, String token) {
    return cancelUnitJoinRequestUseCase.execute(requestId: requestId, token: token);
  }
}
