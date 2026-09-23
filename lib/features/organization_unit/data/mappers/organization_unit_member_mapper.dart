import 'package:savings_api_frontend/features/organization_unit/data/models/organization_unit_member_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';

class OrganizationUnitMemberMapper {
  const OrganizationUnitMemberMapper._();

  static OrganizationUnitMember toDomain(OrganizationUnitMemberModel model) {
    return OrganizationUnitMember(
      id: model.id,
      organizationUnitId: model.organizationUnitId,
      userId: model.userId,
      status: model.status,
      joinedAt: DateTime.parse(model.joinedAt),
      roleId: model.roleId,
      roleName: model.roleName,
      systemRole: model.systemRole,
    );
  }
}
