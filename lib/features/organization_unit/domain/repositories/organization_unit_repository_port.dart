import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';

abstract class OrganizationUnitRepositoryPort {
  Future<List<OrganizationUnit>> getUnits({required int tenantId, required String token});

  Future<OrganizationUnit> createUnit({
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    required String token,
  });

  Future<OrganizationUnit> updateUnit({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    String? status,
    required String token,
  });

  Future<void> deleteUnit({required int id, required int tenantId, required String token});

  Future<OrganizationUnitMember> assignMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  });

  Future<void> removeMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  });

  Future<void> assignManager({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  });

  Future<void> transferManager({
    required int id,
    required int tenantId,
    required int newUserId,
    required String token,
  });

  Future<void> removeManager({required int id, required int tenantId, required String token});

  /// `null` cuando la unidad no tiene encargado vigente.
  Future<UnitManager?> getManager({required int id, required int tenantId, required String token});

  Future<({UnitJoinRequest request, String message})> requestToJoinUnit({required int id, required String token});

  Future<UnitJoinRequest> cancelUnitJoinRequest({required int requestId, required String token});

  Future<List<UnitJoinRequest>> getMyUnitJoinRequests({required String token});

  Future<void> assignMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  });

  Future<void> removeMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  });

  Future<List<UnitJoinRequest>> getUnitJoinRequests({required int id, required int tenantId, required String token});

  Future<({UnitJoinRequest request, OrganizationUnitMember member})> approveUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  });

  Future<UnitJoinRequest> rejectUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  });
}
