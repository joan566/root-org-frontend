import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_unit_manager_use_case.dart';

class GetUnitManagerController {
  final GetUnitManagerUseCase getUnitManagerUseCase;

  GetUnitManagerController(this.getUnitManagerUseCase);

  Future<UnitManager?> execute(int id, int tenantId, String token) {
    return getUnitManagerUseCase.execute(id: id, tenantId: tenantId, token: token);
  }
}
