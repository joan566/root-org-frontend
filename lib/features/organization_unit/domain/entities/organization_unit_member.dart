/// Sentinel para distinguir "no tocar este campo" de "poner este campo en
/// null" en [OrganizationUnitMember.copyWith] -- roleId/roleName/systemRole
/// son legítimamente nullable como valor final (sin rol, sin encargado), así
/// que un `copyWith` que solo hiciera `x ?? this.x` nunca podría limpiarlos.
class _Unset {
  const _Unset();
}

const _unset = _Unset();

class OrganizationUnitMember {
  final int id;
  final int organizationUnitId;
  final int userId;
  final String status;
  final DateTime joinedAt;
  final int? roleId;
  final String? roleName;
  final String? systemRole;

  OrganizationUnitMember({
    required this.id,
    required this.organizationUnitId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    required this.roleId,
    required this.roleName,
    required this.systemRole
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// Usado para aplicar en memoria el resultado de una mutación cuyo
  /// endpoint no devuelve el member actualizado (asignar/remover rol o
  /// encargado) -- ver docs/01-features/organizacion.md. Pasar `null`
  /// explícito limpia el campo; omitirlo lo deja igual.
  OrganizationUnitMember copyWith({
    String? status,
    Object? roleId = _unset,
    Object? roleName = _unset,
    Object? systemRole = _unset,
  }) {
    return OrganizationUnitMember(
      id: id,
      organizationUnitId: organizationUnitId,
      userId: userId,
      status: status ?? this.status,
      joinedAt: joinedAt,
      roleId: identical(roleId, _unset) ? this.roleId : roleId as int?,
      roleName: identical(roleName, _unset) ? this.roleName : roleName as String?,
      systemRole: identical(systemRole, _unset) ? this.systemRole : systemRole as String?,
    );
  }
}
