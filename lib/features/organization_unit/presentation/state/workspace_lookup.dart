import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';

/// Resuelve la organización activa de la sesión -- lo necesita toda pantalla
/// del Workspace departamental (ver docs/01-features/organizacion.md
/// §"Workspace"), que solo recibe `unitId` por constructor (el resto del
/// contexto ya es global, no hace falta cargarlo aparte -- ver esa misma
/// sección para el razonamiento). Sin estado propio: se recalcula en cada
/// llamada a partir de `AuthProvider`/`TenantSessionController`, mismo
/// patrón que ya usaba `StructureTab._tenantId` antes de esta duplicación.
UserTenant? activeUserTenant(BuildContext context) {
  final auth = context.read<AuthProvider>();
  final tenants = auth.session?.user.tenants ?? [];
  return context.read<TenantSessionController>().resolveActive(tenants);
}
