/// Capacidades dentro del Workspace de un departamento, resueltas por
/// código de permiso real (ADR-021: `GET /me/permissions?tenantId=&
/// organizationUnitId={id}` -- la lista ya viene deduplicada con la unión
/// "lo que puede en todo el tenant" + "lo que puede en esa unidad y su
/// subárbol", así que no hace falta combinar con un `isTenantAdmin` aparte
/// como antes).
///
/// `manager.assign`/`manager.remove` son deliberadamente dobles: gatean
/// tanto asignar/remover al encargado de la unidad como asignar/remover el
/// `Role` de un integrante con alcance de unidad -- mismo código para las
/// dos acciones, confirmado por backend.
class DepartmentCapabilities {
  final Set<String> codes;

  const DepartmentCapabilities(this.codes);

  bool get canAssignMember => codes.contains('core.organization_unit.member.assign');
  bool get canRemoveMember => codes.contains('core.organization_unit.member.remove');

  bool get canAssignManager => codes.contains('core.organization_unit.manager.assign');
  bool get canRemoveManager => codes.contains('core.organization_unit.manager.remove');

  bool get canReadJoinRequests => codes.contains('core.organization_unit.join_request.read');
  bool get canApproveJoinRequest => codes.contains('core.organization_unit.join_request.approve');
  bool get canRejectJoinRequest => codes.contains('core.organization_unit.join_request.reject');

  /// Alias de "herramienta visible en el Home del Workspace" -- una
  /// capacidad agregada por tarjeta, no por botón individual.
  bool get canManageMembers => canAssignMember || canRemoveMember;

  bool get canManageRoles => canAssignManager || canRemoveManager;

  bool get canManageJoinRequests => canReadJoinRequests || canApproveJoinRequest || canRejectJoinRequest;
}
