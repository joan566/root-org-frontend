import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_manager.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_users_provider.dart';

/// Cache global de la estructura organizacional (departamentos), cacheada
/// por tenant -- sobrevive a navegar fuera de la sección Organización y
/// volver, igual que `AuthProvider`/`TenantSessionController`. Solo se
/// vuelve a consultar el backend en la primera visita a cada organización,
/// o cuando se pide explícitamente (pull-to-refresh).
///
/// Los usuarios del tenant (necesarios para resolver encargados/miembros de
/// cada departamento) ya no se cachean aquí -- viven en `TenantUsersProvider`
/// (única fuente de `GET /tenant/{id}/users`), que se recibe por parámetro
/// para no duplicar esa consulta con la que hace `UsersTab`.
class OrganizationUnitsProvider extends ChangeNotifier {
  final Map<int, List<DepartmentSummary>> _summariesByTenant = {};

  /// Encargado por unidad (ADR-021: `GET /organization-units/{id}/manager`
  /// es la única fuente -- ya no viene embebido en `GET /organization-units`).
  /// Se carga por unidad, no por tenant, porque ese es el grano del endpoint.
  final Map<int, UnitManager?> _managerByUnitId = {};

  bool isLoaded(int tenantId) => _summariesByTenant.containsKey(tenantId);

  List<DepartmentSummary> summariesFor(int tenantId) => _summariesByTenant[tenantId] ?? const [];

  bool isManagerLoaded(int unitId) => _managerByUnitId.containsKey(unitId);

  UnitManager? managerFor(int unitId) => _managerByUnitId[unitId];

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos.
  Future<void> loadManager(int unitId, int tenantId, String token) async {
    final manager = await OrganizationUnitInjection.getUnitManagerController().execute(unitId, tenantId, token);
    _managerByUnitId[unitId] = manager;
    notifyListeners();
  }

  /// Aplica en memoria el resultado de asignar/transferir/remover encargado
  /// -- ninguna de esas tres acciones devuelve el encargado actualizado (ver
  /// `OrganizationUnitManagerActionsUseCase`), así que quien llama construye
  /// el `UnitManager` con los datos ya conocidos (`userId` recién enviado) en
  /// vez de recargar.
  void setManager(int unitId, UnitManager? manager) {
    _managerByUnitId[unitId] = manager;
    notifyListeners();
  }

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos; así un fallo nunca deja el cache a medias. Solo dispara
  /// `tenantUsersProvider.load` si aún no estaba cacheado -- si `UsersTab` ya
  /// lo cargó para este tenant, esta llamada no repite `GET /tenant/{id}/users`.
  Future<void> load(
      int tenantId,
      String token,
      TenantUsersProvider tenantUsersProvider,
      ) async {

    final units = await OrganizationUnitInjection
        .getOrganizationUnitsController()
        .getUnits(tenantId, token);

    if (!tenantUsersProvider.isLoaded(tenantId)) {
      await tenantUsersProvider.load(tenantId, token);
    }

    _summariesByTenant[tenantId] = units
        .map((unit) => DepartmentSummary(unit: unit))
        .toList();

    notifyListeners();
  }

  void add(int tenantId, DepartmentSummary summary) {
    _summariesByTenant[tenantId] = [...summariesFor(tenantId), summary];
    notifyListeners();
  }

  void applyUpdate(int tenantId, DepartmentSummary updated) {
    _summariesByTenant[tenantId] = summariesFor(tenantId).map((s) => s.unit.id == updated.unit.id ? updated : s).toList();
    notifyListeners();
  }

  void clear() {
    _summariesByTenant.clear();
    _managerByUnitId.clear();
    notifyListeners();
  }
}
