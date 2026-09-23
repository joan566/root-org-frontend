import 'package:savings_api_frontend/features/tenant/data/datasources/tenant_api.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/join_request_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/register_tenant_with_owner_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/tenant_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/mappers/tenant_user_mapper.dart';
import 'package:savings_api_frontend/features/tenant/data/models/join_request_info_model.dart';
import 'package:savings_api_frontend/features/tenant/data/models/register_tenant_with_owner_model.dart';
import 'package:savings_api_frontend/features/tenant/data/models/tenant_model.dart';
import 'package:savings_api_frontend/features/tenant/data/models/tenant_user_model.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

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
  Future<List<TenantMember>> getTenantUsers({required int tenantId, required String token}) async {
    final json = await tenantApi.getTenantUsers(tenantId: tenantId, token: token);
    final users = json['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => TenantUserMapper.toDomain(TenantUserModel.fromJson(u)))
        .toList();
  }

  @override
  Future<({JoinRequest request, String message})> requestToJoinTenant({required String tenantCode, required String token}) async {
    final json = await tenantApi.requestToJoinTenant(tenantCode: tenantCode, token: token);
    final model = JoinRequestInfoModel.fromJson(json['joinRequestInfo']);
    return (request: JoinRequestMapper.toDomain(model), message: json['message'] as String);
  }

  @override
  Future<List<JoinRequest>> getPendingJoinRequests({required int tenantId, required String token}) async {
    final json = await tenantApi.getPendingJoinRequests(tenantId: tenantId, token: token);
    final requests = json['requests'] as List<dynamic>? ?? [];
    return requests
        .map((r) => JoinRequestMapper.toDomain(JoinRequestInfoModel.fromJson(r)))
        .toList();
  }

  @override
  Future<JoinRequest> approveJoinRequest({required int tenantId, required int requestId, required String token}) async {
    final json = await tenantApi.approveJoinRequest(tenantId: tenantId, requestId: requestId, token: token);
    final model = JoinRequestInfoModel.fromJson(json['joinRequestInfo']);
    return JoinRequestMapper.toDomain(model);
  }

  @override
  Future<JoinRequest> rejectJoinRequest({required int tenantId, required int requestId, required String token}) async {
    final json = await tenantApi.rejectJoinRequest(tenantId: tenantId, requestId: requestId, token: token);
    final model = JoinRequestInfoModel.fromJson(json['joinRequestInfo']);
    return JoinRequestMapper.toDomain(model);
  }

  @override
  Future<JoinRequest> cancelJoinRequest({required int requestId, required String token}) async {
    final json = await tenantApi.cancelJoinRequest(requestId: requestId, token: token);
    final model = JoinRequestInfoModel.fromJson(json['joinRequestInfo']);
    return JoinRequestMapper.toDomain(model);
  }

  @override
  Future<List<JoinRequest>> getMyJoinRequests({required String token}) async {
    final json = await tenantApi.getMyJoinRequests(token: token);
    final requests = json['requests'] as List<dynamic>? ?? [];
    return requests
        .map((r) => JoinRequestMapper.toDomain(JoinRequestInfoModel.fromJson(r)))
        .toList();
  }

  @override
  Future<Tenant> updateTenant({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  }) async {
    final json = await tenantApi.updateTenant(tenantId: tenantId, name: name, description: description, token: token);
    final model = TenantModel.fromJson(json['tenantInfo']);
    return TenantMapper.toDomain(model);
  }
}
