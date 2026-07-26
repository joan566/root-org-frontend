import 'package:savings_api_frontend/features/tenant/domain/entities/join_tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';

abstract class TenantRepositoryPort {
  Future<RegisterTenantWithOwner> registerTenantWithOwner({
    required String name,
    required String description,
    required int userId,
    required String token
  });

  Future<JoinTenant> joinTenant({
    required int userId,
    required String tenantCode,
    required String token
  });
}