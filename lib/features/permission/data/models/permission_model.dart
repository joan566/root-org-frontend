class PermissionModel {
  final int id;
  final String module;
  final String code;
  final String name;
  final String description;
  final bool active;
  final bool defaultForMember;

  PermissionModel({
    required this.id,
    required this.module,
    required this.code,
    required this.name,
    required this.description,
    required this.active,
    required this.defaultForMember,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      module: json['module'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      defaultForMember: json['defaultForMember'],
    );
  }
}
