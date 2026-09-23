class RoleModel {
  final int id;
  final int tenantId;
  final String name;
  final String description;
  final String? systemRole;

  RoleModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.systemRole,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      tenantId: json['tenantId'],
      name: json['name'],
      description: json['description'],
      systemRole: json['systemRole'],
    );
  }
}
