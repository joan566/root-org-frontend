import 'package:savings_api_frontend/features/tenant/data/models/join_request_info_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';

class JoinRequestMapper {
  const JoinRequestMapper._();

  static JoinRequest toDomain(JoinRequestInfoModel model) {
    return JoinRequest(
      id: model.id,
      userId: model.userId,
      requesterName: model.requesterName,
      requesterLastName: model.requesterLastName,
      requesterEmail: model.requesterEmail,
      tenantId: model.tenantId,
      tenantName: model.tenantName,
      tenantCode: model.tenantCode,
      status: JoinRequestStatus.fromRaw(model.status),
      requestedAt: model.requestedAt,
      resolvedAt: model.resolvedAt,
      resolvedByUserId: model.resolvedByUserId,
    );
  }
}
