import 'package:savings_api_frontend/features/organization_unit/data/datasources/organization_unit_api.dart';
import 'package:savings_api_frontend/features/organization_unit/data/mappers/organization_unit_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/mappers/organization_unit_member_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/mappers/unit_join_request_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/organization_unit_member_model.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/organization_unit_model.dart';
import 'package:savings_api_frontend/features/organization_unit/data/mappers/unit_manager_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/unit_join_request_model.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/unit_manager_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/repositories/organization_unit_repository_port.dart';

class OrganizationUnitRepositoryAdapter implements OrganizationUnitRepositoryPort {
  final OrganizationUnitApi organizationUnitApi;

  OrganizationUnitRepositoryAdapter(this.organizationUnitApi);

  @override
  Future<List<OrganizationUnit>> getUnits({required int tenantId, required String token}) async {
    final json = await organizationUnitApi.listUnits(tenantId: tenantId, token: token);
    final units = json['organizationUnits'] as List<dynamic>? ?? [];
    return units.map((u) => OrganizationUnitMapper.toDomain(OrganizationUnitModel.fromJson(u))).toList();
  }

  @override
  Future<OrganizationUnit> createUnit({
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    required String token,
  }) async {
    final json = await organizationUnitApi.createUnit(
      tenantId: tenantId,
      name: name,
      description: description,
      parentUnitId: parentUnitId,
      token: token,
    );
    return OrganizationUnitMapper.toDomain(OrganizationUnitModel.fromJson(json['organizationUnit']));
  }

  @override
  Future<OrganizationUnit> updateUnit({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    String? status,
    required String token,
  }) async {
    final json = await organizationUnitApi.updateUnit(
      id: id,
      tenantId: tenantId,
      name: name,
      description: description,
      parentUnitId: parentUnitId,
      status: status,
      token: token,
    );
    return OrganizationUnitMapper.toDomain(OrganizationUnitModel.fromJson(json['organizationUnit']));
  }

  @override
  Future<void> deleteUnit({required int id, required int tenantId, required String token}) async {
    await organizationUnitApi.deleteUnit(id: id, tenantId: tenantId, token: token);
  }

  @override
  Future<OrganizationUnitMember> assignMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) async {
    final json = await organizationUnitApi.assignMember(id: id, tenantId: tenantId, userId: userId, token: token);
    return OrganizationUnitMemberMapper.toDomain(OrganizationUnitMemberModel.fromJson(json['member']));
  }

  @override
  Future<void> removeMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) async {
    await organizationUnitApi.removeMember(id: id, tenantId: tenantId, userId: userId, token: token);
  }

  @override
  Future<void> assignManager({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) async {
    await organizationUnitApi.assignManager(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  @override
  Future<void> transferManager({
    required int id,
    required int tenantId,
    required int newUserId,
    required String token,
  }) async {
    await organizationUnitApi.transferManager(id: id, tenantId: tenantId, newUserId: newUserId, token: token);
  }

  @override
  Future<void> removeManager({required int id, required int tenantId, required String token}) async {
    await organizationUnitApi.removeManager(id: id, tenantId: tenantId, token: token);
  }

  @override
  Future<UnitManager?> getManager({required int id, required int tenantId, required String token}) async {
    final json = await organizationUnitApi.getManager(id: id, tenantId: tenantId, token: token);
    final manager = json['manager'] as Map<String, dynamic>?;
    if (manager == null) return null;
    return UnitManagerMapper.toDomain(UnitManagerModel.fromJson(manager));
  }

  @override
  Future<({UnitJoinRequest request, String message})> requestToJoinUnit({required int id, required String token}) async {
    final json = await organizationUnitApi.requestToJoinUnit(id: id, token: token);
    final model = UnitJoinRequestModel.fromJson(json['joinRequestInfo']);
    return (request: UnitJoinRequestMapper.toDomain(model), message: json['message'] as String);
  }

  @override
  Future<UnitJoinRequest> cancelUnitJoinRequest({required int requestId, required String token}) async {
    final json = await organizationUnitApi.cancelUnitJoinRequest(requestId: requestId, token: token);
    final model = UnitJoinRequestModel.fromJson(json['joinRequestInfo']);
    return UnitJoinRequestMapper.toDomain(model);
  }

  @override
  Future<List<UnitJoinRequest>> getMyUnitJoinRequests({required String token}) async {
    final json = await organizationUnitApi.getMyUnitJoinRequests(token: token);
    final requests = json['requests'] as List<dynamic>? ?? [];
    return requests.map((r) => UnitJoinRequestMapper.toDomain(UnitJoinRequestModel.fromJson(r))).toList();
  }

  @override
  Future<void> assignMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) async {
    await organizationUnitApi.assignMemberRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  @override
  Future<void> removeMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) async {
    await organizationUnitApi.removeMemberRole(id: id, tenantId: tenantId, userId: userId, roleId: roleId, token: token);
  }

  @override
  Future<List<UnitJoinRequest>> getUnitJoinRequests({required int id, required int tenantId, required String token}) async {
    final json = await organizationUnitApi.listUnitJoinRequests(id: id, tenantId: tenantId, token: token);
    final requests = json['requests'] as List<dynamic>? ?? [];
    return requests.map((r) => UnitJoinRequestMapper.toDomain(UnitJoinRequestModel.fromJson(r))).toList();
  }

  @override
  Future<({UnitJoinRequest request, OrganizationUnitMember member})> approveUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) async {
    final json = await organizationUnitApi.approveUnitJoinRequest(id: id, requestId: requestId, tenantId: tenantId, token: token);
    final request = UnitJoinRequestMapper.toDomain(UnitJoinRequestModel.fromJson(json['joinRequestInfo']));
    final member = OrganizationUnitMemberMapper.toDomain(OrganizationUnitMemberModel.fromJson(json['member']));
    return (request: request, member: member);
  }

  @override
  Future<UnitJoinRequest> rejectUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) async {
    final json = await organizationUnitApi.rejectUnitJoinRequest(id: id, requestId: requestId, tenantId: tenantId, token: token);
    return UnitJoinRequestMapper.toDomain(UnitJoinRequestModel.fromJson(json['joinRequestInfo']));
  }
}
