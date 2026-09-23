class UnitJoinRequestModel {
  final int id;
  final int userId;
  final String? requesterName;
  final String? requesterLastName;
  final String? requesterEmail;
  final int organizationUnitId;
  final String organizationUnitName;
  final int tenantId;
  final String status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final int? resolvedByUserId;

  UnitJoinRequestModel({
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

  factory UnitJoinRequestModel.fromJson(Map<String, dynamic> json) {
    return UnitJoinRequestModel(
      id: json['id'],
      userId: json['userId'],
      requesterName: json['requesterName'],
      requesterLastName: json['requesterLastName'],
      requesterEmail: json['requesterEmail'],
      organizationUnitId: json['organizationUnitId'],
      organizationUnitName: json['organizationUnitName'],
      tenantId: json['tenantId'],
      status: json['status'],
      requestedAt: DateTime.parse(json['requestedAt']),
      resolvedAt: json['resolvedAt'] == null ? null : DateTime.parse(json['resolvedAt']),
      resolvedByUserId: json['resolvedByUserId'],
    );
  }
}
