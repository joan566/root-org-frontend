class Role {
  final int id;
  final int tenantId;
  final String name;
  final String description;
  final String? systemRole;

  Role({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.systemRole,
  });
}
