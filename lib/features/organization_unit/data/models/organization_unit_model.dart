import 'package:savings_api_frontend/features/organization_unit/data/models/organization_unit_member_model.dart';

class OrganizationUnitModel {
  final int id;
  final int tenantId;
  final int? parentUnitId;
  final String name;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<OrganizationUnitMemberModel> members;

  OrganizationUnitModel({
    required this.id,
    required this.tenantId,
    required this.parentUnitId,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
  });

  /// `members` (y `managerInfo`, que no se modela -- ver
  /// `OrganizationUnit.copyWith`) solo vienen embebidos en la respuesta de
  /// `GET /organization-units`; las respuestas de acciones individuales
  /// (crear/editar/asignar encargado) no traen esa key en absoluto.
  factory OrganizationUnitModel.fromJson(Map<String, dynamic> json) {
    return OrganizationUnitModel(
      id: json['id'],
      tenantId: json['tenantId'],
      parentUnitId: json['parentUnitId'],
      name: json['name'],
      description: json['description'] ?? '',
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      members: (json['members'] as List<dynamic>? ?? []).map((m) => OrganizationUnitMemberModel.fromJson(m)).toList(),
    );
  }
}
