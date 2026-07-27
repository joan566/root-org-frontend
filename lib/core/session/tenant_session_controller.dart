import 'package:flutter/foundation.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

/// Recuerda cuál organización (tenant) está activa durante la sesión.
///
/// Aditivo respecto a [AuthProvider]/[LoginSesion]: no los modifica, vive al
/// lado. Igual que la sesión de auth, es solo en memoria — se resetea al
/// reiniciar la app. Ver docs/frontend-navigation-redesign.md §8.
class TenantSessionController extends ChangeNotifier {
  UserTenant? _explicitActive;
  bool _hasPassedGate = false;

  /// Resuelve la organización activa para la lista de tenants dada:
  /// - Si hay una elección explícita y sigue siendo válida, se usa esa.
  /// - Si el usuario pertenece a una sola organización, se autoselecciona.
  /// - Si pertenece a 2+ sin elección explícita, devuelve null (requiere
  ///   que el usuario elija en `SelectTenantScreen`).
  ///
  /// No confundir con [hasPassedGate]: este método sigue autoseleccionando
  /// con 1 organización para el resto de la app (dashboard, organización,
  /// etc.) — el gate de login exige una confirmación explícita incluso con
  /// una sola, pero eso se controla aparte para no romper el resto de
  /// consumidores de `resolveActive`.
  UserTenant? resolveActive(List<UserTenant> tenants) {
    final explicit = _explicitActive;
    if (explicit != null && tenants.any((t) => t.id == explicit.id)) {
      return explicit;
    }
    if (tenants.length == 1) return tenants.first;
    return null;
  }

  void setActive(UserTenant tenant) {
    _explicitActive = tenant;
    notifyListeners();
  }

  /// True una vez que el usuario pasó explícitamente por el gate de
  /// selección de organización (`SelectTenantScreen`, `isInitialSelection:
  /// true`) en esta sesión — ver docs/frontend-navigation-redesign.md.
  bool get hasPassedGate => _hasPassedGate;

  void markGatePassed() {
    _hasPassedGate = true;
    notifyListeners();
  }

  void clear() {
    _explicitActive = null;
    _hasPassedGate = false;
    notifyListeners();
  }
}
