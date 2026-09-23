class UnitManagerModel {
  final int userId;
  final int organizationUnitId;
  final String grantedAt;

  UnitManagerModel({
    required this.userId,
    required this.organizationUnitId,
    required this.grantedAt,
  });

  factory UnitManagerModel.fromJson(Map<String, dynamic> json) {
    return UnitManagerModel(
      userId: json['userId'],
      organizationUnitId: json['organizationUnitId'],
      grantedAt: json['grantedAt'],
    );
  }
}
