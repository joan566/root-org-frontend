/// Capacidades a nivel de todo el tenant (Organización, sin unidad
/// concreta). Dos fuentes conviven aquí, deliberadamente:
///
/// - `roles` (ADR-011, `UserTenant.roles`): heurística vieja por nombre de
///   rol ("Admin"/"Member"), todavía en uso para `isAdmin`/`canManageUsers`
///   porque no hay código de permiso confirmado para "administrar usuarios
///   del tenant" ni para "qué layout de pestañas mostrar" -- pendiente.
/// - `permissionCodes` (ADR-021, `GET /me/permissions?tenantId=` sin
///   `organizationUnitId`): códigos reales, confirmados por backend, para
///   `core.organization_unit.*` y `core.role.*`.
///
/// No mezclar: cada getter usa una sola fuente. Cuando llegue el código real
/// para `isAdmin`/`canManageUsers`, esos getters migran a `permissionCodes`
/// y `roles` se puede borrar de esta clase.
class OrganizationCapabilities {
  final List<String> roles;
  final Set<String> permissionCodes;

  const OrganizationCapabilities(this.roles, this.permissionCodes);

  /// Rol "Admin" tal como lo devuelve el backend hoy (ver ADR-011: el
  /// creador de una organización siempre recibe `roles: ["Admin"]`, quien
  /// se une por código siempre recibe `roles: ["Member"]`). Pendiente de
  /// reemplazo por código de permiso real.
  bool get isAdmin => roles.any((r) => r.toLowerCase() == 'admin');

  /// Pendiente de código real -- gestión de usuarios del tenant (pestaña
  /// "Usuarios", invitar/remover) no está en el catálogo `core.organization_
  /// unit.*`/`core.role.*` confirmado.
  bool get canManageUsers => isAdmin;

  bool get canCreateUnit => permissionCodes.contains('core.organization_unit.create');
  bool get canReadUnit => permissionCodes.contains('core.organization_unit.read');
  bool get canUpdateUnit => permissionCodes.contains('core.organization_unit.update');
  bool get canDeleteUnit => permissionCodes.contains('core.organization_unit.delete');
  bool get canAssignUnitMember => permissionCodes.contains('core.organization_unit.member.assign');
  bool get canRemoveUnitMember => permissionCodes.contains('core.organization_unit.member.remove');
  bool get canAssignUnitManager => permissionCodes.contains('core.organization_unit.manager.assign');
  bool get canRemoveUnitManager => permissionCodes.contains('core.organization_unit.manager.remove');
  bool get canReadUnitJoinRequests => permissionCodes.contains('core.organization_unit.join_request.read');
  bool get canApproveUnitJoinRequest => permissionCodes.contains('core.organization_unit.join_request.approve');
  bool get canRejectUnitJoinRequest => permissionCodes.contains('core.organization_unit.join_request.reject');

  /// FAB "Crear departamento" en Organización→Estructura.
  bool get canManageOrganizationStructure => canCreateUnit;

  bool get canCreateRole => permissionCodes.contains('core.role.create');
  bool get canReadRoles => permissionCodes.contains('core.role.read');
  bool get canUpdateRole => permissionCodes.contains('core.role.update');
  bool get canDeleteRole => permissionCodes.contains('core.role.delete');
  bool get canAssignPermissionToRole => permissionCodes.contains('core.role.permission.assign');
  bool get canRemovePermissionFromRole => permissionCodes.contains('core.role.permission.remove');
  bool get canAssignRoleToUser => permissionCodes.contains('core.role.user.assign');
  bool get canRemoveRoleFromUser => permissionCodes.contains('core.role.user.remove');
}
