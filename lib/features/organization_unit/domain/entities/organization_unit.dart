import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';

class OrganizationUnit {
  final int id;
  final int tenantId;
  final int? parentUnitId;
  final String name;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrganizationUnitMember> members;

  OrganizationUnit({
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

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// Las respuestas de acciones individuales (`POST/PUT /organization-units`,
  /// `POST/DELETE .../manager`) no traen `members` embebido -- solo
  /// `GET /organization-units` lo trae. Por eso [members] no se sobrescribe
  /// por defecto: quien aplica una unidad devuelta por una de esas acciones
  /// sobre el estado local debe pasar explícitamente `members: this.members`
  /// (el actual) si quiere preservarlo.
  OrganizationUnit copyWith({
    List<OrganizationUnitMember>? members,
    String? status,
  }) {
    return OrganizationUnit(
      id: id,
      tenantId: tenantId,
      parentUnitId: parentUnitId,
      name: name,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      members: members ?? this.members,
    );
  }
}
