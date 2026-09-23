class OrganizationUnitMemberModel {
  final int id;
  final int organizationUnitId;
  final int userId;
  final String status;
  final String joinedAt;
  final int? roleId;
  final String? roleName;
  final String? systemRole;

  OrganizationUnitMemberModel({
    required this.id,
    required this.organizationUnitId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    required this.roleId,
    required this.roleName,
    required this.systemRole
  });

  factory OrganizationUnitMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationUnitMemberModel(
      id: json['id'],
      organizationUnitId: json['organizationUnitId'],
      userId: json['userId'],
      status: json['status'],
      joinedAt: json['joinedAt'],
      roleId: json['roleId'],
      roleName: json['roleName'],
      systemRole: json['systemRole']
    );
  }
}
