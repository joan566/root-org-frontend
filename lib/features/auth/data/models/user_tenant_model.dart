import 'package:savings_api_frontend/features/tenant/data/models/tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';

class UserTenantModel {
  final int id;
  final TenantModel tenant;
  final int userId;
  final List<String> roles;
  final String status;

  UserTenantModel({
    required this.id,
    required this.tenant,
    required this.userId,
    required this.roles,
    required this.status,
  });

  factory UserTenantModel.fromJson(Map<String, dynamic> json) {
    return UserTenantModel(
      id: json['id'],
      tenant: TenantModel.fromJson(json['tenantInfo']),
      userId: json['userId'],
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'],
    );
  }
}