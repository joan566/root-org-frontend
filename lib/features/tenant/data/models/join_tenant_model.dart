import 'package:savings_api_frontend/features/auth/data/models/user_tenant_model.dart';

class JoinTenantModel {
  final bool successfully;
  final String message;
  final UserTenantModel userTenant;

  JoinTenantModel({
    required this.successfully,
    required this.message,
    required this.userTenant
  });

  factory JoinTenantModel.fromJson(Map<String, dynamic> json) {
    return JoinTenantModel(
        successfully: json['successfully'],
        message: json['message'],
        userTenant: UserTenantModel.fromJson(json['userTenantInfo']));
  }
}