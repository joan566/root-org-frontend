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
    this.emailVerified = false,
    this.phoneNumber,
    this.status,
  });

  final int id;
  final String? name;
  final String? lastName;
  final String? email;
  final bool emailVerified;
  final String? phoneNumber;
  final String? status;
  final List<OrganizationUnitMembership> organizationUnitMemberships;

  AppUser copyWith({bool? emailVerified}) {
    return AppUser(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber,
      status: status,
      organizationUnitMemberships: organizationUnitMemberships,
    );
  }
}
