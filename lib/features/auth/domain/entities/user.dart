import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

class User {
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
  final List<UserTenant> tenants;
  final String createdAt;
  final String updatedAt;

  User({
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

}