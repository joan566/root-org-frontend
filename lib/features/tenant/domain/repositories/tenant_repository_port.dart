import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/register_tenant_with_owner.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';

abstract class TenantRepositoryPort {
  Future<RegisterTenantWithOwner> registerTenantWithOwner({
    required String name,
    required String description,
    required int userId,
    required String token
  });

  Future<List<TenantMember>> getTenantUsers({
    required int tenantId,
    required String token,
  });

  /// `message` es el texto humano que manda el backend (ej. "Tu solicitud
  /// fue enviada correctamente. Debes esperar la aprobación de un
  /// administrador de {tenantName}.") -- se muestra tal cual en el diálogo
  /// de éxito, no se reconstruye en el cliente.
  Future<({JoinRequest request, String message})> requestToJoinTenant({
    required String tenantCode,
    required String token,
  });

  Future<List<JoinRequest>> getPendingJoinRequests({
    required int tenantId,
    required String token,
  });

  Future<JoinRequest> approveJoinRequest({
    required int tenantId,
    required int requestId,
    required String token,
  });

  Future<JoinRequest> rejectJoinRequest({
    required int tenantId,
    required int requestId,
    required String token,
  });

  Future<JoinRequest> cancelJoinRequest({
    required int requestId,
    required String token,
  });

  Future<List<JoinRequest>> getMyJoinRequests({
    required String token,
  });

  Future<Tenant> updateTenant({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  });
}
