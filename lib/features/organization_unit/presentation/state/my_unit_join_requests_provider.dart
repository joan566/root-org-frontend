import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';

/// Cache global de las solicitudes de ingreso a departamentos del usuario
/// autenticado (`GET /organization-units/join-requests/mine`), igual que
/// `OrganizationUnitsProvider`/`TenantUsersProvider`: sobrevive a navegar
/// fuera de Organización y volver, solo se vuelve a consultar el backend en
/// la primera visita o en pull-to-refresh, y las mutaciones (solicitar/
/// cancelar) se aplican en memoria vía [applyResult] en vez de recargar.
///
/// A diferencia de esos dos, este cache **no** está indexado por tenant: el
/// endpoint `mine` no recibe `tenantId` y devuelve las solicitudes del
/// usuario a cualquier unidad de cualquier tenant. Por eso "primera visita"
/// aplica una sola vez por sesión de la app, no una vez por tenant -- no
/// convertir esto en un `Map<int, List<UnitJoinRequest>>` por tenant, sería
/// una consulta que el backend no soporta.
class MyUnitJoinRequestsProvider extends ChangeNotifier {
  List<UnitJoinRequest> _requests = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<UnitJoinRequest> get requests => _requests;

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos; así un fallo nunca deja el cache a medias.
  Future<void> load(String token) async {
    _requests = await OrganizationUnitInjection.getMyUnitJoinRequestsController().getMyUnitJoinRequests(token);
    _loaded = true;
    notifyListeners();
  }

  /// Aplica el resultado de `requestToJoin`/`cancel` directamente sobre el
  /// cache en memoria -- nunca se refetchea la lista completa tras mutar.
  void applyResult(UnitJoinRequest updated) {
    final idx = _requests.indexWhere((r) => r.id == updated.id);
    _requests = idx == -1 ? [..._requests, updated] : [for (final r in _requests) r.id == updated.id ? updated : r];
    notifyListeners();
  }

  void clear() {
    _requests = [];
    _loaded = false;
    notifyListeners();
  }
}
