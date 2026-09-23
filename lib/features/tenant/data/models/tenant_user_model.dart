class TenantUserModel {
  final int userId;
  final String name;
  final String? lastName;
  final String email;
  final String status;
  final List<String> roles;

  TenantUserModel({
    required this.userId,
    required this.name,
    required this.lastName,
    required this.email,
    required this.status,
    required this.roles,
  });

  factory TenantUserModel.fromJson(Map<String, dynamic> json) {
    return TenantUserModel(
      userId: json['userId'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      status: json['status'],
      roles: json['roles'] == null ? [] : List<String>.from(json['roles']),
    );
  }
}
