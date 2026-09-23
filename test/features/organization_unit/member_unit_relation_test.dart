import 'package:flutter_test/flutter_test.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/member_unit_relation.dart';

const _currentUserId = 42;

OrganizationUnit _unit({List<OrganizationUnitMember> members = const []}) {
  return OrganizationUnit(
    id: 1,
    tenantId: 1,
    parentUnitId: null,
    name: 'Ventas',
    description: 'Departamento comercial',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    members: members,
  );
}

OrganizationUnitMember _member({required int userId, String status = 'ACTIVE'}) {
  return OrganizationUnitMember(
    id: 10,
    organizationUnitId: 1,
    userId: userId,
    status: status,
    joinedAt: DateTime(2026, 1, 1),
    roleId: null,
    roleName: null,
    systemRole: null,
  );
}

UnitJoinRequest _request({required int id, required UnitJoinRequestStatus status, required DateTime requestedAt, int organizationUnitId = 1}) {
  return UnitJoinRequest(
    id: id,
    userId: _currentUserId,
    requesterName: 'Juan',
    requesterLastName: 'Pérez',
    requesterEmail: 'juan@x.com',
    organizationUnitId: organizationUnitId,
    organizationUnitName: 'Ventas',
    tenantId: 1,
    status: status,
    requestedAt: requestedAt,
    resolvedAt: null,
    resolvedByUserId: null,
  );
}

void main() {
  group('MemberUnitRelation.resolve', () {
    test('member: user is an active member of the unit', () {
      final unit = _unit(members: [_member(userId: _currentUserId)]);

      final relation = MemberUnitRelation.resolve(unit: unit, currentUserId: _currentUserId, latestRequestForUnit: null);

      expect(relation.status, MemberUnitRelationStatus.member);
    });

    test('member wins even with a REJECTED request in history -- membership is checked first', () {
      final unit = _unit(members: [_member(userId: _currentUserId)]);
      final rejected = _request(id: 1, status: UnitJoinRequestStatus.rejected, requestedAt: DateTime(2026, 1, 1));

      final relation = MemberUnitRelation.resolve(unit: unit, currentUserId: _currentUserId, latestRequestForUnit: rejected);

      expect(relation.status, MemberUnitRelationStatus.member);
    });

    test('notMember: inactive membership record does not count as member', () {
      final unit = _unit(members: [_member(userId: _currentUserId, status: 'INACTIVE')]);

      final relation = MemberUnitRelation.resolve(unit: unit, currentUserId: _currentUserId, latestRequestForUnit: null);

      expect(relation.status, MemberUnitRelationStatus.notMember);
    });

    test('notMember: no membership and no request history', () {
      final relation = MemberUnitRelation.resolve(unit: _unit(), currentUserId: _currentUserId, latestRequestForUnit: null);

      expect(relation.status, MemberUnitRelationStatus.notMember);
    });

    test('pending: latest request is PENDING', () {
      final request = _request(id: 1, status: UnitJoinRequestStatus.pending, requestedAt: DateTime(2026, 1, 1));

      final relation = MemberUnitRelation.resolve(unit: _unit(), currentUserId: _currentUserId, latestRequestForUnit: request);

      expect(relation.status, MemberUnitRelationStatus.pending);
      expect(relation.latestRequest, request);
    });

    test('rejected: latest request is REJECTED', () {
      final request = _request(id: 1, status: UnitJoinRequestStatus.rejected, requestedAt: DateTime(2026, 1, 1));

      final relation = MemberUnitRelation.resolve(unit: _unit(), currentUserId: _currentUserId, latestRequestForUnit: request);

      expect(relation.status, MemberUnitRelationStatus.rejected);
    });

    test('notMember: latest request is APPROVED but no active membership record (edge case)', () {
      final request = _request(id: 1, status: UnitJoinRequestStatus.approved, requestedAt: DateTime(2026, 1, 1));

      final relation = MemberUnitRelation.resolve(unit: _unit(), currentUserId: _currentUserId, latestRequestForUnit: request);

      expect(relation.status, MemberUnitRelationStatus.notMember);
    });

    test('notMember: latest request is CANCELLED -- can request again', () {
      final request = _request(id: 1, status: UnitJoinRequestStatus.cancelled, requestedAt: DateTime(2026, 1, 1));

      final relation = MemberUnitRelation.resolve(unit: _unit(), currentUserId: _currentUserId, latestRequestForUnit: request);

      expect(relation.status, MemberUnitRelationStatus.notMember);
    });
  });

  group('MemberUnitRelation.latestRequestByUnit', () {
    test('keeps only the most recent request per unit, regardless of input order', () {
      final older = _request(id: 1, status: UnitJoinRequestStatus.rejected, requestedAt: DateTime(2026, 1, 1), organizationUnitId: 1);
      final newer = _request(id: 2, status: UnitJoinRequestStatus.pending, requestedAt: DateTime(2026, 2, 1), organizationUnitId: 1);
      final otherUnit = _request(id: 3, status: UnitJoinRequestStatus.pending, requestedAt: DateTime(2026, 1, 15), organizationUnitId: 2);

      // Deliberately out of chronological order.
      final result = MemberUnitRelation.latestRequestByUnit([newer, older, otherUnit]);

      expect(result[1], newer);
      expect(result[2], otherUnit);
      expect(result.length, 2);
    });

    test('empty input yields an empty map', () {
      expect(MemberUnitRelation.latestRequestByUnit([]), isEmpty);
    });
  });
}
