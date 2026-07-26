import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import '../../../auth/domain/entities/user_tenant.dart';

class RegisterTenantWithOwner {
  final bool successfully;
  final String message;
  final Tenant tenant;
  final UserTenant userTenant;

  RegisterTenantWithOwner({
    required this.successfully,
    required this.message,
    required this.tenant,
    required this.userTenant
  });
}