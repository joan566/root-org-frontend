import 'package:savings_api_frontend/features/organization_unit/data/models/unit_manager_model.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';

class UnitManagerMapper {
  const UnitManagerMapper._();

  static UnitManager toDomain(UnitManagerModel model) {
    return UnitManager(
      userId: model.userId,
      organizationUnitId: model.organizationUnitId,
      grantedAt: DateTime.parse(model.grantedAt),
    );
  }
}
