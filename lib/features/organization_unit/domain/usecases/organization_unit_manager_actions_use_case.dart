import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Asignar, transferir y remover al encargado de una unidad -- agrupados por
/// el mismo motivo que `OrganizationUnitMemberActionsUseCase`. Asignar
/// requiere que el usuario ya sea integrante ACTIVE de la unidad
/// (RN-ORG-008); esa regla vive en el backend, aquí solo se propaga el error
/// si no se cumple. Ninguna de las tres respuestas trae el encargado/unidad
/// actualizados -- quien llame debe refrescar `GET /organization-units`.
class OrganizationUnitManagerActionsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  OrganizationUnitManagerActionsUseCase(this.organizationUnitRepositoryPort);

  Future<void> assign({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.assignManager(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  Future<void> transfer({
    required int id,
    required int tenantId,
    required int newUserId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.transferManager(id: id, tenantId: tenantId, newUserId: newUserId, token: token);
  }

  Future<void> remove({required int id, required int tenantId, required String token}) {
    return organizationUnitRepositoryPort.removeManager(id: id, tenantId: tenantId, token: token);
  }
}
