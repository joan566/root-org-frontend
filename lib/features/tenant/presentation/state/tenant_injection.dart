import 'package:savings_api_frontend/features/tenant/data/datasources/tenant_api.dart';
import 'package:savings_api_frontend/features/tenant/data/repositories/tenant_repository_adapter.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_my_join_requests_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_pending_join_requests_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/get_tenant_users_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_request_actions_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/join_tenant_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/register_tenant_with_owner_use_case.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/update_tenant_use_case.dart';
import 'package:savings_api_frontend/features/tenant/presentation/join_tenant/state/join_tenant_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/create_tenant/state/register_tenant_with_owner_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/get_my_join_requests_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/get_pending_join_requests_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/get_tenant_users_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/join_request_actions_controller.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/update_tenant_controller.dart';

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

  static GetTenantUsersController getTenantUsersController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = GetTenantUsersUseCase(repository);

    return GetTenantUsersController(useCase);
  }

  static GetPendingJoinRequestsController getPendingJoinRequestsController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = GetPendingJoinRequestsUseCase(repository);

    return GetPendingJoinRequestsController(useCase);
  }

  static GetMyJoinRequestsController getMyJoinRequestsController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = GetMyJoinRequestsUseCase(repository);

    return GetMyJoinRequestsController(useCase);
  }

  static JoinRequestActionsController joinRequestActionsController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = JoinRequestActionsUseCase(repository);

    return JoinRequestActionsController(useCase);
  }

  static UpdateTenantController updateTenantController() {
    final tenantApi = TenantApi();
    final repository = TenantRepositoryAdapter(tenantApi);
    final useCase = UpdateTenantUseCase(repository);

    return UpdateTenantController(useCase);
  }
}