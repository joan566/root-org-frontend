class OrganizationUnitMembership {
  const OrganizationUnitMembership({
    this.id,
    this.organizationUnitId,
    this.userId,
    this.status,
    this.joinedAt,
  });

  final int? id;
  final int? organizationUnitId;
  final int? userId;
  final String? status;
  final String? joinedAt;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.organizationUnitMemberships,
    this.name,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.status,
  });

  final int id;
  final String? name;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? status;
  final List<OrganizationUnitMembership> organizationUnitMemberships;
}
