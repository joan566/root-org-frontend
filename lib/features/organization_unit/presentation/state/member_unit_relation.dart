import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';

enum MemberUnitRelationStatus { member, notMember, pending, rejected }

/// Composición de presentación (no una entidad de dominio, mismo criterio
/// que `DepartmentSummary`): la relación del usuario autenticado con un
/// departamento, para la vista Member de Estructura Organizacional.
class MemberUnitRelation {
  final MemberUnitRelationStatus status;
  final UnitJoinRequest? latestRequest;

  const MemberUnitRelation({required this.status, this.latestRequest});

  /// La membresía real (`unit.members`) se chequea SIEMPRE primero -- nunca
  /// se infiere "miembro" a partir de una solicitud `APPROVED`, porque el
  /// usuario pudo haber sido removido después por un admin sin que eso
  /// cambie el status histórico de la solicitud.
  static MemberUnitRelation resolve({
    required OrganizationUnit unit,
    required int currentUserId,
    required UnitJoinRequest? latestRequestForUnit,
  }) {
    final isMember = unit.members.any((m) => m.userId == currentUserId && m.isActive);
    if (isMember) return const MemberUnitRelation(status: MemberUnitRelationStatus.member);

    final latest = latestRequestForUnit;
    if (latest == null) return const MemberUnitRelation(status: MemberUnitRelationStatus.notMember);

    switch (latest.status) {
      case UnitJoinRequestStatus.pending:
        return MemberUnitRelation(status: MemberUnitRelationStatus.pending, latestRequest: latest);
      case UnitJoinRequestStatus.rejected:
        return MemberUnitRelation(status: MemberUnitRelationStatus.rejected, latestRequest: latest);
      case UnitJoinRequestStatus.approved:
      case UnitJoinRequestStatus.cancelled:
        return const MemberUnitRelation(status: MemberUnitRelationStatus.notMember);
    }
  }

  /// Reduce la lista completa de "mis solicitudes" a la más reciente por
  /// unidad (por `requestedAt`) una sola vez por `build()`, en vez de
  /// escanearla por cada card -- O(N+M) en vez de O(N×M).
  static Map<int, UnitJoinRequest> latestRequestByUnit(List<UnitJoinRequest> myRequests) {
    final result = <int, UnitJoinRequest>{};
    for (final r in myRequests) {
      final existing = result[r.organizationUnitId];
      if (existing == null || r.requestedAt.isAfter(existing.requestedAt)) {
        result[r.organizationUnitId] = r;
      }
    }
    return result;
  }
}
