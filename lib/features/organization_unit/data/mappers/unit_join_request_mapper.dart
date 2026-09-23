import 'package:savings_api_frontend/features/organization_unit/data/models/unit_join_request_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';

class UnitJoinRequestMapper {
  const UnitJoinRequestMapper._();

  static UnitJoinRequest toDomain(UnitJoinRequestModel model) {
    return UnitJoinRequest(
      id: model.id,
      userId: model.userId,
      requesterName: model.requesterName,
      requesterLastName: model.requesterLastName,
      requesterEmail: model.requesterEmail,
      organizationUnitId: model.organizationUnitId,
      organizationUnitName: model.organizationUnitName,
      tenantId: model.tenantId,
      status: UnitJoinRequestStatus.fromRaw(model.status),
      requestedAt: model.requestedAt,
      resolvedAt: model.resolvedAt,
      resolvedByUserId: model.resolvedByUserId,
    );
  }
}
