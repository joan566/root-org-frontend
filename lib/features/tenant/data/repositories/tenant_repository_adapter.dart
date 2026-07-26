import 'package:savings_api_frontend/features/tenant/data/datasources/tenant_api.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/join_tenant_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/register_tenant_with_owner_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/models/join_tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/data/models/register_tenant_with_owner_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/join_tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';

import '../../domain/repositories/tenant_repository_port.dart';

class TenantRepositoryAdapter implements TenantRepositoryPort {
  final TenantApi tenantApi;

  TenantRepositoryAdapter(this.tenantApi);

  @override
  Future<RegisterTenantWithOwner> registerTenantWithOwner({
    required String name,
    required String description,
    required int userId,
    required String token
  }) async {
    final json = await tenantApi.createTenantWithOwner(
        name: name,
        description: description,
        userId: userId,
        token: token
    );

    final model = RegisterTenantWithOwnerModel.fromJson(json);
    return RegisterTenantWithOwnerMapper.toDomain(model);
  }

  @override
  Future<JoinTenant> joinTenant({required int userId, required String tenantCode, required String token}) async{
    final json = await tenantApi.jointTenant(
        userId: userId, tenantCode: tenantCode,
        token: token
    );

    final model = JoinTenantModel.fromJson(json);
    return JoinTenantMapper.toDomain(model);
  }
}