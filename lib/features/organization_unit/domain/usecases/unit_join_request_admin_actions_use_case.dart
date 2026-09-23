import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Aprobar/rechazar una solicitud de ingreso a una unidad -- lado
/// encargado/admin. No incluye `cancel` (autoservicio del propio
/// solicitante, ya cubierto por `CancelUnitJoinRequestUseCase`).
class UnitJoinRequestAdminActionsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  UnitJoinRequestAdminActionsUseCase(this.organizationUnitRepositoryPort);

  Future<({UnitJoinRequest request, OrganizationUnitMember member})> approve({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.approveUnitJoinRequest(id: id, requestId: requestId, tenantId: tenantId, token: token);
  }

  Future<UnitJoinRequest> reject({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.rejectUnitJoinRequest(id: id, requestId: requestId, tenantId: tenantId, token: token);
  }
}
