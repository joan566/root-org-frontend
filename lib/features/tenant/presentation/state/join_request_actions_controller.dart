import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_request_actions_use_case.dart';

class JoinRequestActionsController {
  final JoinRequestActionsUseCase joinRequestActionsUseCase;

  JoinRequestActionsController(this.joinRequestActionsUseCase);

  Future<JoinRequest> approve(int tenantId, int requestId, String token) {
    return joinRequestActionsUseCase.approve(tenantId: tenantId, requestId: requestId, token: token);
  }

  Future<JoinRequest> reject(int tenantId, int requestId, String token) {
    return joinRequestActionsUseCase.reject(tenantId: tenantId, requestId: requestId, token: token);
  }

  Future<JoinRequest> cancel(int requestId, String token) {
    return joinRequestActionsUseCase.cancel(requestId: requestId, token: token);
  }
}
