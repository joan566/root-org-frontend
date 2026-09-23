enum UnitJoinRequestStatus {
  pending,
  approved,
  rejected,
  cancelled;

  static UnitJoinRequestStatus fromRaw(String raw) {
    switch (raw.toUpperCase()) {
      case 'APPROVED':
        return UnitJoinRequestStatus.approved;
      case 'REJECTED':
        return UnitJoinRequestStatus.rejected;
      case 'CANCELLED':
        return UnitJoinRequestStatus.cancelled;
      default:
        return UnitJoinRequestStatus.pending;
    }
  }
}

/// Solicitud de ingreso a un departamento (`OrganizationUnit`), ver
/// docs/01-features/organizacion.md. Mismo patrón que `JoinRequest` (feature
/// `tenant`) pero a nivel unidad organizacional.
class UnitJoinRequest {
  final int id;
  final int userId;
  final String? requesterName;
  final String? requesterLastName;
  final String? requesterEmail;
  final int organizationUnitId;
  final String organizationUnitName;
  final int tenantId;
  final UnitJoinRequestStatus status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final int? resolvedByUserId;

  UnitJoinRequest({
    required this.id,
    required this.userId,
    required this.requesterName,
    required this.requesterLastName,
    required this.requesterEmail,
    required this.organizationUnitId,
    required this.organizationUnitName,
    required this.tenantId,
    required this.status,
    required this.requestedAt,
    required this.resolvedAt,
    required this.resolvedByUserId,
  });
}
