class Permission {
  final int id;
  final String module;
  final String code;
  final String name;
  final String description;
  final bool active;
  final bool defaultForMember;

  Permission({
    required this.id,
    required this.module,
    required this.code,
    required this.name,
    required this.description,
    required this.active,
    required this.defaultForMember,
  });
}
