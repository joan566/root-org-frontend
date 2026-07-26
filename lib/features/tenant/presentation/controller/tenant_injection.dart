import 'package:savings_api_frontend/features/tenant/data/datasources/tenant_api.dart';
import 'package:savings_api_frontend/features/tenant/data/repositories/tenant_repository_adapter.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_tenant_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/register_tenant_with_owner_use_case.dart';
import 'package:savings_api_frontend/features/tenant/presentation/controller/join_tenant_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/controller/register_tenant_with_owner_controller.dart';

class TenantInjection {
  static RegisterTenantWithOwnerController registerTenantWithOwnerController() {
    final tenantApi =  TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = RegisterTenantWithOwnerUseCase(repository);

    return RegisterTenantWithOwnerController(useCase);
  }

  static JoinTenantController joinTenantController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = JoinTenantUseCase(repository);

    return JoinTenantController(useCase);
  }
}