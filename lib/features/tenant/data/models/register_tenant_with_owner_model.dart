import 'package:savings_api_frontend/features/auth/data/models/user_tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/data/models/tenant_model.dart';

class RegisterTenantWithOwnerModel {
  final bool successfully;
  final String message;
  final TenantModel tenant;
  final UserTenantModel userTenant;
  
  RegisterTenantWithOwnerModel({
    required this.successfully,
    required this.message,
    required this.tenant,
    required this.userTenant
  });
  
  factory RegisterTenantWithOwnerModel.fromJson(Map<String, dynamic> json) {
    return RegisterTenantWithOwnerModel(
        successfully: json['successfully'], 
        message: json['message'], 
        tenant: TenantModel.fromJson(json['tenantInfo']),
        userTenant: UserTenantModel.fromJson(json['userTenantInfo'])
    );
  }
}