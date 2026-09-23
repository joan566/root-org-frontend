class JoinRequestInfoModel {
  final int id;
  final int userId;
  final String? requesterName;
  final String? requesterLastName;
  final String? requesterEmail;
  final int tenantId;
  final String tenantName;
  final String tenantCode;
  final String status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final int? resolvedByUserId;

  JoinRequestInfoModel({
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

  factory JoinRequestInfoModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestInfoModel(
      id: json['id'],
      userId: json['userId'],
      requesterName: json['requesterName'],
      requesterLastName: json['requesterLastName'],
      requesterEmail: json['requesterEmail'],
      tenantId: json['tenantId'],
      tenantName: json['tenantName'],
      tenantCode: json['tenantCode'],
      status: json['status'],
      requestedAt: DateTime.parse(json['requestedAt']),
      resolvedAt: json['resolvedAt'] == null ? null : DateTime.parse(json['resolvedAt']),
      resolvedByUserId: json['resolvedByUserId'],
    );
  }
}
