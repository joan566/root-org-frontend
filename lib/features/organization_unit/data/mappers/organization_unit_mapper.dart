import 'package:savings_api_frontend/features/organization_unit/data/mappers/organization_unit_member_mapper.dart';
import 'package:savings_api_frontend/features/organization_unit/data/models/organization_unit_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';

class OrganizationUnitMapper {
  const OrganizationUnitMapper._();

  static OrganizationUnit toDomain(OrganizationUnitModel model) {
    return OrganizationUnit(
      id: model.id,
      tenantId: model.tenantId,
      parentUnitId: model.parentUnitId,
      name: model.name,
      description: model.description,
      status: model.status,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      members: model.members.map(OrganizationUnitMemberMapper.toDomain).toList(),
    );
  }
}
