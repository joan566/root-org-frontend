import 'package:savings_api_frontend/features/organization_unit/data/datasources/organization_unit_api.dart';
import 'package:savings_api_frontend/features/organization_unit/data/repositories/organization_unit_repository_adapter.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/cancel_unit_join_request_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/create_organization_unit_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/delete_organization_unit_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_my_unit_join_requests_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_organization_units_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/organization_unit_manager_actions_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_unit_manager_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/get_unit_manager_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/organization_unit_member_actions_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/request_to_join_unit_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/update_organization_unit_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/cancel_unit_join_request_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/create_organization_unit_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/delete_organization_unit_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/data/datasources/role_api.dart';
import 'package:savings_api_frontend/features/organization_unit/data/repositories/role_repository_adapter.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/list_roles_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/list_roles_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/get_unit_join_requests_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/usecases/unit_join_request_admin_actions_use_case.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/get_my_unit_join_requests_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/get_organization_units_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/get_unit_join_requests_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_manager_actions_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_member_actions_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/request_to_join_unit_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/unit_join_request_admin_actions_controller.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/update_organization_unit_controller.dart';

class OrganizationUnitInjection {
  static GetOrganizationUnitsController getOrganizationUnitsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = GetOrganizationUnitsUseCase(repository);

    return GetOrganizationUnitsController(useCase);
  }

  static CreateOrganizationUnitController createOrganizationUnitController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = CreateOrganizationUnitUseCase(repository);

    return CreateOrganizationUnitController(useCase);
  }

  static UpdateOrganizationUnitController updateOrganizationUnitController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = UpdateOrganizationUnitUseCase(repository);

    return UpdateOrganizationUnitController(useCase);
  }

  static DeleteOrganizationUnitController deleteOrganizationUnitController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = DeleteOrganizationUnitUseCase(repository);

    return DeleteOrganizationUnitController(useCase);
  }

  static OrganizationUnitMemberActionsController organizationUnitMemberActionsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = OrganizationUnitMemberActionsUseCase(repository);

    return OrganizationUnitMemberActionsController(useCase);
  }

  static OrganizationUnitManagerActionsController organizationUnitManagerActionsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = OrganizationUnitManagerActionsUseCase(repository);

    return OrganizationUnitManagerActionsController(useCase);
  }

  static GetUnitManagerController getUnitManagerController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = GetUnitManagerUseCase(repository);

    return GetUnitManagerController(useCase);
  }

  static RequestToJoinUnitController requestToJoinUnitController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = RequestToJoinUnitUseCase(repository);

    return RequestToJoinUnitController(useCase);
  }

  static CancelUnitJoinRequestController cancelUnitJoinRequestController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = CancelUnitJoinRequestUseCase(repository);

    return CancelUnitJoinRequestController(useCase);
  }

  static GetMyUnitJoinRequestsController getMyUnitJoinRequestsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = GetMyUnitJoinRequestsUseCase(repository);

    return GetMyUnitJoinRequestsController(useCase);
  }

  static ListRolesController listRolesController() {
    final api = RoleApi();
    final repository = RoleRepositoryAdapter(api);
    final useCase = ListRolesUseCase(repository);

    return ListRolesController(useCase);
  }

  static GetUnitJoinRequestsController getUnitJoinRequestsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = GetUnitJoinRequestsUseCase(repository);

    return GetUnitJoinRequestsController(useCase);
  }

  static UnitJoinRequestAdminActionsController unitJoinRequestAdminActionsController() {
    final api = OrganizationUnitApi();
    final repository = OrganizationUnitRepositoryAdapter(api);
    final useCase = UnitJoinRequestAdminActionsUseCase(repository);

    return UnitJoinRequestAdminActionsController(useCase);
  }
}
