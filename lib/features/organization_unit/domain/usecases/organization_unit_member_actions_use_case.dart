import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

/// Asignar y remover integrantes de una unidad -- agrupados porque son 2
/// variantes del mismo verbo ("gestionar membresía"), mismo patrón que
/// `JoinRequestActionsUseCase` en la feature tenant.
class OrganizationUnitMemberActionsUseCase {
  final OrganizationUnitRepositoryPort organizationUnitRepositoryPort;

  OrganizationUnitMemberActionsUseCase(this.organizationUnitRepositoryPort);

  Future<OrganizationUnitMember> assign({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.assignMember(id: id, tenantId: tenantId, userId: userId, token: token);
  }

  Future<void> remove({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.removeMember(id: id, tenantId: tenantId, userId: userId, token: token);
  }

  Future<void> assignRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.assignMemberRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  Future<void> removeRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return organizationUnitRepositoryPort.removeMemberRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }
}
