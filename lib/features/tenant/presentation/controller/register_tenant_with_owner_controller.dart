import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';
import 'package:savings_api_frontend/features/tenant/domain/usecases/register_tenant_with_owner_use_case.dart';

class RegisterTenantWithOwnerController {
  final RegisterTenantWithOwnerUseCase registerTenantWithOwnerUseCase;

  RegisterTenantWithOwnerController(
      this.registerTenantWithOwnerUseCase
  );

  Future<RegisterTenantWithOwner> registerTenantWithOwner(
    String name, String description, int userId, String token
  ) async {
    return await registerTenantWithOwnerUseCase.execute(
        name: name, description: description, userId: userId, token: token);
  }
}