import '../../../auth/domain/entities/user_tenant.dart';

class JoinTenant {
  final bool successfully;
  final String message;
  final UserTenant userTenant;

  JoinTenant({
    required this.successfully,
    required this.message,
    required this.userTenant
  });
}