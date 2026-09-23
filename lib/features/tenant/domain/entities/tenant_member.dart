class TenantMember {
  final int userId;
  final String name;
  final String? lastName;
  final String email;
  final String status;
  final List<String> roles;

  TenantMember({
    required this.userId,
    required this.name,
    required this.lastName,
    required this.email,
    required this.status,
    required this.roles,
  });

  String get fullName => [name, lastName].where((p) => p != null && p.isNotEmpty).join(' ');
}
