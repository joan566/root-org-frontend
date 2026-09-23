import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/role.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';

/// Cache global de los roles del tenant activo -- se cachea por tenant igual
/// que `OrganizationUnitsProvider`/`TenantUsersProvider` porque se lee cada
/// vez que se abre "Asignar encargado", no solo en la primera visita a
/// Estructura.
class RolesProvider extends ChangeNotifier {
  final Map<int, List<Role>> _rolesByTenant = {};

  bool isLoaded(int tenantId) => _rolesByTenant.containsKey(tenantId);

  List<Role> rolesFor(int tenantId) => _rolesByTenant[tenantId] ?? const [];

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos.
  Future<void> load(int tenantId, String token) async {
    final roles = await OrganizationUnitInjection.listRolesController().execute(tenantId, token);
    _rolesByTenant[tenantId] = roles;
    notifyListeners();
  }

  void clear() {
    _rolesByTenant.clear();
    notifyListeners();
  }
}
