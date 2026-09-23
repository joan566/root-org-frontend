import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/permission/domain/entities/permission.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permission_injection.dart';

/// Cache global de `GET /me/permissions` (ADR-021) -- reemplaza los gates
/// por nombre/systemRole de rol (`OrganizationCapabilities`,
/// `DepartmentCapabilities`). Dos cachés separadas porque son dos llamadas
/// distintas al backend:
/// - `_tenantWide`: solo `tenantId` -- lo que el usuario puede en todo el
///   tenant (vistas generales: dashboard, administración de tenant).
/// - `_byUnit`: `tenantId` + `organizationUnitId` -- ya viene deduplicada
///   con la unión "tenant-wide" + "esa unidad y su subárbol" (ver doc
///   ADR-021), así que no hay que combinarla manualmente con `_tenantWide`.
class PermissionsProvider extends ChangeNotifier {
  final Map<int, List<Permission>> _tenantWide = {};
  final Map<String, List<Permission>> _byUnit = {};

  static String _unitKey(int tenantId, int organizationUnitId) => '$tenantId:$organizationUnitId';

  bool isTenantLoaded(int tenantId) => _tenantWide.containsKey(tenantId);

  bool isUnitLoaded(int tenantId, int organizationUnitId) => _byUnit.containsKey(_unitKey(tenantId, organizationUnitId));

  Set<String> codesForTenant(int tenantId) => (_tenantWide[tenantId] ?? const []).map((p) => p.code).toSet();

  Set<String> codesForUnit(int tenantId, int organizationUnitId) =>
      (_byUnit[_unitKey(tenantId, organizationUnitId)] ?? const []).map((p) => p.code).toSet();

  /// No atrapa errores -- se propagan a quien llama para que decida cómo
  /// mostrarlos.
  Future<void> loadForTenant(int tenantId, String token) async {
    final permissions = await PermissionInjection.getMyPermissionsController().execute(tenantId, token);
    _tenantWide[tenantId] = permissions;
    notifyListeners();
  }

  Future<void> loadForUnit(int tenantId, int organizationUnitId, String token) async {
    final permissions = await PermissionInjection.getMyPermissionsController().execute(
      tenantId,
      token,
      organizationUnitId: organizationUnitId,
    );
    _byUnit[_unitKey(tenantId, organizationUnitId)] = permissions;
    notifyListeners();
  }

  void clear() {
    _tenantWide.clear();
    _byUnit.clear();
    notifyListeners();
  }
}
