import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_my_join_requests_use_case.dart';

class GetMyJoinRequestsController {
  final GetMyJoinRequestsUseCase getMyJoinRequestsUseCase;

  GetMyJoinRequestsController(this.getMyJoinRequestsUseCase);

  Future<List<JoinRequest>> getMyJoinRequests(String token) {
    return getMyJoinRequestsUseCase.execute(token: token);
  }
}
