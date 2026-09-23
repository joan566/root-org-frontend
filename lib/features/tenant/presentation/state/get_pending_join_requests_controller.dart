import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_pending_join_requests_use_case.dart';

class GetPendingJoinRequestsController {
  final GetPendingJoinRequestsUseCase getPendingJoinRequestsUseCase;

  GetPendingJoinRequestsController(this.getPendingJoinRequestsUseCase);

  Future<List<JoinRequest>> getPendingJoinRequests(int tenantId, String token) {
    return getPendingJoinRequestsUseCase.execute(tenantId: tenantId, token: token);
  }
}
