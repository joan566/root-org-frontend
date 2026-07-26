
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';

class UserTenant {
  final int id;
  final Tenant tenant;
  final int userId;
  final List<String> roles;
  final String status;

  UserTenant({
    required this.id,
    required this.tenant,
    required this.userId,
    required this.roles,
    required this.status,
  });
}