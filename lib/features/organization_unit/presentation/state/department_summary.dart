import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';

/// Composición de presentación para una card de la pestaña Estructura: la
/// unidad, que ya trae `members` embebido desde `GET /organization-units`.
/// El encargado ya NO es parte de esto (ADR-021: se resuelve aparte por
/// `OrganizationUnitsProvider.managerFor(unitId)`, alimentado por
/// `GET /organization-units/{id}/manager` -- ya no viene embebido en la
/// unidad). No es una entidad de dominio -- vive junto a
/// `OrganizationUnitsProvider` porque es parte del estado global cacheado de
/// esta feature, no de un widget en particular.
class DepartmentSummary {
  final OrganizationUnit unit;

  DepartmentSummary({required this.unit});

  int get memberCount => unit.members.where((m) => m.isActive).length;
}
