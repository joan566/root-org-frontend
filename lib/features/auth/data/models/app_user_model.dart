import '../../domain/entities/app_user.dart';

class OrganizationUnitMembershipModel {
  const OrganizationUnitMembershipModel({
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

  factory OrganizationUnitMembershipModel.fromJson(Map<String, dynamic> json) {
    return OrganizationUnitMembershipModel(
      id: _intValue(json['id']),
      organizationUnitId: _intValue(json['organizationUnitId']),
      userId: _intValue(json['userId']),
      status: json['status'] as String?,
      joinedAt: json['joinedAt'] as String?,
    );
  }

  OrganizationUnitMembership toEntity() {
    return OrganizationUnitMembership(
      id: id,
      organizationUnitId: organizationUnitId,
      userId: userId,
      status: status,
      joinedAt: joinedAt,
    );
  }
}

class AppUserModel {
  const AppUserModel({
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
  final List<OrganizationUnitMembershipModel> organizationUnitMemberships;

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final id = _intValue(json['id']);
    if (id == null) {
      throw const FormatException('User response is missing its id.');
    }

    final membershipsJson = json['organizationUnitMemberInfos'];
    final memberships = membershipsJson == null
        ? const <OrganizationUnitMembershipModel>[]
        : (membershipsJson as List<dynamic>)
              .map(
                (membership) => OrganizationUnitMembershipModel.fromJson(
                  Map<String, dynamic>.from(membership as Map),
                ),
              )
              .toList(growable: false);

    return AppUserModel(
      id: id,
      name: json['name'] as String?,
      lastName: json['lastName'] as String?,
      email: (json['userEmail'] ?? json['email']) as String?,
      phoneNumber: json['phoneNumber'] as String?,
      status: json['status'] as String?,
      organizationUnitMemberships: memberships,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      status: status,
      organizationUnitMemberships: organizationUnitMemberships
          .map((membership) => membership.toEntity())
          .toList(growable: false),
    );
  }
}

int? _intValue(Object? value) => value is num ? value.toInt() : null;
