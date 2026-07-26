# Plan de refactor frontend — ADR-011 (Sistema de Permisos)

> Contrato de referencia: [ADR-011-sistema-permisos.md](./ADR-011-sistema-permisos.md)

Estado: **implementado**. Verificado con `flutter analyze` (0 errores).

Nota de implementación: al eliminar `profile_model.dart`/`profile_mapper.dart`/`profile.dart` (decisión 2) aparecieron 6 imports huérfanos que ningún grep de "uso real" detecta (`get_user.dart`, `update_profile.dart`, `get_user_mapper.dart`, `update_profile_mapper.dart`, `get_user_model.dart`, `update_profile_model.dart` importaban esas clases sin usarlas). Se limpiaron como parte del punto 17.

## Alcance

Migrar el frontend Flutter al nuevo contrato de ADR-011 (`role`→`roles`, request de join-tenant sin `role`) y dejar preparado el manejo de errores 403, sin introducir decisiones de autorización basadas en `roles` en el cliente.

Un solo modelo (`UserTenantModel.fromJson`, en `lib/features/auth/data/models/user_tenant_model.dart`) alimenta las cuatro respuestas que traen `roles` (login, perfil, join-tenant, create-with-owner), así que el cambio del campo se hace en un único punto y se propaga a los cuatro flujos.

Auditoría previa confirmó que `userTenantInfos`, `userEmail`, `userInfo` y `tenantInfo` **ya están migrados** en el código actual (eran inconsistencias preexistentes entre la doc vieja y el backend, corregidas antes de este sprint). Solo falta migrar `role`→`roles` y el contrato de request de join-tenant.

## Decisiones tomadas

Estas tres decisiones se definieron con el usuario antes de ejecutar el refactor, porque exceden un renombrado mecánico de campos:

1. **Tarjeta "Permisos globales" del dashboard personal** (`personal_dashboard_page.dart`, `metrics_summary_block.dart`): hoy muestra un número (`15` o `5`) calculado como `rawRole.toUpperCase() == 'OWNER' || 'ADMIN' ? 15 : 5` — un valor inventado, exactamente el tipo de inferencia de autorización que el ADR prohíbe.
   **Decisión: eliminarla.** El grid de métricas pasa de 4 a 3 tarjetas (Organizaciones, Rol activo, Módulos listos).

2. **`ProfileModel` / `ProfileMapper` / `Profile`** (`lib/features/user/data/models/profile_model.dart`, `lib/features/user/data/mappers/profile_mapper.dart`, `lib/features/user/domain/entities/profile.dart`): usan la clave JSON vieja `userTenants` y se confirmó que **no tienen ningún caller real** — el flujo de perfil usa `GetUserModel`/`UpdateProfileModel`, no estas clases.
   **Decisión: eliminar los 3 archivos** en vez de migrarlos, para no dejar código muerto con una clave desalineada que nadie corregirá después.

3. **Manejo de errores HTTP**: los 3 datasources (`auth_api.dart`, `user_api.dart`, `tenant_api.dart`) lanzan hoy `Exception(message)` genérico para cualquier status HTTP no-2xx — 400/401/403/404 son indistinguibles para quien los captura.
   **Decisión: introducir `ApiException`** (clase compartida con `statusCode`/`errorCode`/`message`), usada por los 3 datasources. Es transparente para el código existente: su `toString()` devuelve solo el `message`, así que los ~15 `catch` que hacen `e.toString().replaceAll("Exception: ", "")` en las páginas siguen funcionando sin tocarlos. Deja el terreno preparado para cuando el backend empiece a disparar 403 en Sprint 4 (Gestión Financiera).

4. **Cómo mostrar múltiples roles en UI**: donde ya existe un chip/badge (`RoleChip`, `_RoleChip` de `tenant_page.dart`), se renderiza **un chip por rol** (`Wrap` de badges). Donde el rol se muestra como texto plano en línea (stat "Rol Principal", listado de organizaciones recientes), se usa `roles.join(', ')`.

## Grupos de cambio

### A. Modelo compartido `role` → `roles`

| # | Archivo | Cambio |
|---|---|---|
| 1 | `lib/features/auth/data/models/user_tenant_model.dart` | `role: json['role']` → `roles: List<String>.from(json['roles'] ?? [])`; campo `String role` → `List<String> roles` |
| 2 | `lib/features/auth/domain/entities/user_tenant.dart` | Mismo cambio de campo |
| 3 | `lib/features/auth/data/mappers/user_tenant_mapper.dart` | `roles: model.roles` |

### B. Quitar `role` del request de join-tenant (toda la cadena)

Incluye el `"MEMBER"` hardcodeado que hoy se envía y que el backend ahora ignora — antes era una escalada de privilegios latente (ver ADR).

| # | Archivo | Cambio |
|---|---|---|
| 4 | `lib/features/tenant/presentation/pages/join_tenant_page.dart` | `_controller.joinTenant(user.id, cleanCode, session.token)` — quitar `"MEMBER"` |
| 5 | `lib/features/tenant/presentation/controller/join_tenant_controller.dart` | Quitar parámetro `role` |
| 6 | `lib/features/tenant/domain/usecases/join_tenant_use_case.dart` | Quitar parámetro `role` |
| 7 | `lib/features/tenant/domain/repositories/tenant_repository_port.dart` | Quitar parámetro `role` de la firma |
| 8 | `lib/features/tenant/data/repositories/tenant_repository_adapter.dart` | Quitar parámetro `role`, no reenviarlo |
| 9 | `lib/features/tenant/data/datasources/tenant_api.dart` | `jointTenant(...)` ya no manda `"role"` en el body |

### C. UI — mostrar `roles` (lista) en vez de `role` (string)

| # | Archivo | Cambio |
|---|---|---|
| 10 | `lib/features/user/presentation/widgets/profile/role_Chip.dart` | `RoleChip` recibe `List<String> roles`, renderiza un `Wrap` con un chip por rol |
| 11 | `lib/features/user/presentation/widgets/profile/organizations_section.dart:111` | `RoleChip(roles: org.roles)` |
| 12 | `lib/features/tenant/presentation/pages/tenant_page.dart` | `_RoleChip` mismo tratamiento (chip por rol); `primaryRole` (stat de texto plano "Rol Principal") pasa a `roles.join(', ')` |
| 13 | `lib/features/dashboard/presentation/widgets/personal/recent_organizations_list.dart` | `_translateRole(String)` → `_translateRoles(List<String>)`, traduce cada rol y hace `.join(', ')` |
| 14 | `lib/features/dashboard/presentation/pages/personal/personal_dashboard_page.dart` | `_formatRole` → `_formatRoles(List<String>)` con `.join(', ')`; eliminar `calculatedPermissions` y la inferencia `rawRole.toUpperCase() == 'OWNER'...` (decisión 1) |
| 15 | `lib/features/dashboard/presentation/widgets/personal/metrics_summary_block.dart` | Quitar campo/tile `totalPermissions` — grid pasa de 4 a 3 métricas (decisión 1) |
| 16 | `lib/features/dashboard/presentation/widgets/personal/side_control_panel.dart` | Quitar el passthrough de `totalPermissions` |

### D. Código muerto (decisión 2)

| # | Archivo | Cambio |
|---|---|---|
| 17 | `lib/features/user/data/models/profile_model.dart`, `lib/features/user/data/mappers/profile_mapper.dart`, `lib/features/user/domain/entities/profile.dart` | Eliminar los 3 archivos |

### E. Manejo tipado de errores (decisión 3)

| # | Archivo | Cambio |
|---|---|---|
| 18 | `lib/features/core/errors/api_exception.dart` (nuevo) | `class ApiException implements Exception { statusCode, errorCode, message; @override String toString() => message; }` |
| 19 | `lib/features/auth/data/datasources/auth_api.dart` | `throw Exception(...)` → `throw ApiException(statusCode: response.statusCode, errorCode: decoded['error'] ?? 'UNKNOWN', message: decoded['message'] ?? 'Error inesperado')` |
| 20 | `lib/features/user/data/datasources/user_api.dart` | Mismo cambio en `_post` y `_get` |
| 21 | `lib/features/tenant/data/datasources/tenant_api.dart` | Mismo cambio en `_post` |

## Fuera de alcance

- `lib/features/tenant/data/models/tenant_model.dart`, `register_tenant_with_owner_model.dart`, `join_tenant_model.dart`, `lib/features/user/data/models/get_user_model.dart`, `update_profile_model.dart`, `lib/features/auth/data/models/user_model.dart` — claves `userEmail`/`userInfo`/`tenantInfo`/`userTenantInfos` ya migradas, sin cambios.
- Colores/labels del switch de `_RoleChip` en `tenant_page.dart` (`'administrador'`, `'propietario'`, `'consultor'`) no coinciden con los valores reales que manda el backend (`'Admin'`, etc.) — el switch ya era código muerto cosméticamente antes de este cambio. No se corrige aquí por no ser parte del contrato ADR-011; queda como deuda técnica conocida.
- Extracción de un cliente HTTP compartido entre los 3 datasources (hoy cada `*Api` duplica `_post`/`_get`) — se identificó como oportunidad de limpieza pero no es necesaria para este refactor; `ApiException` se introduce de forma independiente en cada archivo.
