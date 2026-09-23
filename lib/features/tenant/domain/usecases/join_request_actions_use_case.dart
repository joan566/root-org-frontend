import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/domain/repositories/tenant_repository_port.dart';

/// Las 3 acciones que se pueden tomar sobre una solicitud de ingreso ya
/// creada -- agrupadas en un solo caso de uso porque son 3 variantes del
/// mismo verbo ("resolver una solicitud"), no 3 conceptos distintos.
class JoinRequestActionsUseCase {
  final TenantRepositoryPort tenantRepositoryPort;

  JoinRequestActionsUseCase(this.tenantRepositoryPort);

  Future<JoinRequest> approve({required int tenantId, required int requestId, required String token}) {
    return tenantRepositoryPort.approveJoinRequest(tenantId: tenantId, requestId: requestId, token: token);
  }

  Future<JoinRequest> reject({required int tenantId, required int requestId, required String token}) {
    return tenantRepositoryPort.rejectJoinRequest(tenantId: tenantId, requestId: requestId, token: token);
  }

  Future<JoinRequest> cancel({required int requestId, required String token}) {
    return tenantRepositoryPort.cancelJoinRequest(requestId: requestId, token: token);
  }
}
