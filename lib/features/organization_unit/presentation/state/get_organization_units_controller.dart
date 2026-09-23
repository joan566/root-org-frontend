import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_organization_units_use_case.dart';

class GetOrganizationUnitsController {
  final GetOrganizationUnitsUseCase getOrganizationUnitsUseCase;

  GetOrganizationUnitsController(this.getOrganizationUnitsUseCase);

  Future<List<OrganizationUnit>> getUnits(int tenantId, String token) {
    return getOrganizationUnitsUseCase.execute(tenantId: tenantId, token: token);
  }
}
