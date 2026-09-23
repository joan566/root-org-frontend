enum JoinRequestStatus {
  pending,
  approved,
  rejected,
  cancelled;

  static JoinRequestStatus fromRaw(String raw) {
    switch (raw.toUpperCase()) {
      case 'APPROVED':
        return JoinRequestStatus.approved;
      case 'REJECTED':
        return JoinRequestStatus.rejected;
      case 'CANCELLED':
        return JoinRequestStatus.cancelled;
      default:
        return JoinRequestStatus.pending;
    }
  }
}

/// Solicitud de ingreso a una organización (ver
/// docs/01-features/organizaciones.md). `requesterName`/`requesterLastName`/
/// `requesterEmail` vienen `null` en los endpoints "cancel" y "mine" -- el
/// backend no los enriquece ahí (el propio usuario ya los conoce).
class JoinRequest {
  final int id;
  final int userId;
  final String? requesterName;
  final String? requesterLastName;
  final String? requesterEmail;
  final int tenantId;
  final String tenantName;
  final String tenantCode;
  final JoinRequestStatus status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final int? resolvedByUserId;

  JoinRequest({
    required this.id,
    required this.userId,
    required this.requesterName,
    required this.requesterLastName,
    required this.requesterEmail,
    required this.tenantId,
    required this.tenantName,
    required this.tenantCode,
    required this.status,
    required this.requestedAt,
    required this.resolvedAt,
    required this.resolvedByUserId,
  });

  String get requesterFullName =>
      [requesterName, requesterLastName].where((p) => p != null && p.isNotEmpty).join(' ');
}
