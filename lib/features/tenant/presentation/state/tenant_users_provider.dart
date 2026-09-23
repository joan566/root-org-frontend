import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_injection.dart';

/// Cache global de los usuarios (miembros) del tenant activo, cacheada por
/// tenant -- sobrevive a navegar fuera de la sección que la consulte y
/// volver, igual que `OrganizationUnitsProvider`/`TenantSessionController`.
/// Solo se vuelve a consultar el backend en la primera visita a cada
/// organización, o cuando se pide explícitamente (pull-to-refresh). Es la
/// única fuente de `GET /tenant/{id}/users` en la app -- tanto `UsersTab`
/// como `OrganizationUnitsProvider` (que necesita los miembros para resolver
/// encargados/miembros de departamento) leen de aquí en vez de consultar el
/// backend cada uno por su lado. Ver CLAUDE.md §"State management" y
/// docs/01-features/organizacion.md.
class TenantUsersProvider extends ChangeNotifier {
  final Map<int, List<TenantMember>> _membersByTenant = {};

  bool isLoaded(int tenantId) => _membersByTenant.containsKey(tenantId);

  List<TenantMember> membersFor(int tenantId) => _membersByTenant[tenantId] ?? const [];

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos; así un fallo nunca deja el cache a medias.
  Future<void> load(int tenantId, String token) async {
    final members = await TenantInjection.getTenantUsersController().getTenantUsers(tenantId, token);
    _membersByTenant[tenantId] = members;
    notifyListeners();
  }

  TenantMember? findById(int tenantId, int userId) {
    final members = _membersByTenant[tenantId];

    if (members == null) return null;

    try {
      return members.firstWhere(
            (member) => member.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _membersByTenant.clear();
    notifyListeners();
  }
}
