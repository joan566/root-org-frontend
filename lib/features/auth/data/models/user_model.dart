import 'package:savings_api_frontend/features/auth/data/models/user_tenant_model.dart';

class UserModel {
  final int id;
  final String name;
  final String? lastName;
  final String? document;
  final DateTime? dateOfBirth;
  final String? gender;
  final String email;
  final String phoneNumber;
  final String status;
  final String profileStatus;
  final List<UserTenantModel> tenants;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.document,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.profileStatus,
    required this.tenants,
    required this.createdAt,
    required this.updatedAt
  });

  static DateTime? _parseDate(dynamic value) {

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        name: json['name'],
        lastName: json['lastName'],
        document: json['document'],
        dateOfBirth: _parseDate(json['dateOfBirth']),
        gender: json["gender"],
        email: json['userEmail'],
        phoneNumber: json['phoneNumber'],
        status: json['status'],
        profileStatus: json['profileStatus'],
        tenants: json['userTenantInfos'] == null
            ? []
            : (json['userTenantInfos'] as List<dynamic>)
            .map((tenantJson) => UserTenantModel.fromJson(tenantJson))
            .toList(),
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt']
    );
  }
}