# Feature: Organizaciones / Tenant (`lib/features/tenant`)

> **Actualización 2026-07-27 (solicitudes de ingreso):** unirse por código dejó de dar membresía instantánea. El código ahora crea una **solicitud** (`PENDING`) que un admin de esa organización debe aprobar o rechazar; la relación `UserTenant` solo se crea al aprobarla. `SelectTenantScreen` evolucionó a `MyOrganizationsScreen` (ver más abajo) para reflejar esto — ya no es solo un selector de tenant, es el centro donde el usuario ve sus organizaciones, crea/pide unirse, y consulta el estado de sus solicitudes.

## Responsabilidad

Crear organizaciones, solicitar ingreso a ellas por código de invitación (sujeto a aprobación), y listarlas. El concepto de "tenant" es la unidad multi-organización de SUMKEYA (ver [vision-frontend.md](../00-core/01-vision/vision-frontend.md)).

## Pantallas (`presentation/<screen>/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `TenantScreen` | `AppRoutes.tenants` (accesos rápidos del Dashboard) | Lista de organizaciones del usuario, con búsqueda |
| `CreateTenantScreen` | `AppRoutes.createTenant` (accesos rápidos) | Formulario de creación + vista de éxito con código de invitación — **sin cambios**, sigue dando membresía instantánea (asigna al usuario como owner al crear) |
| `JoinTenantScreen` | `AppRoutes.joinTenant` (accesos rápidos) | Formulario de código de invitación + diálogo de éxito. **Cambiado**: ya no asocia al instante — crea una solicitud `PENDING` y muestra el mensaje real del backend ("Tu solicitud fue enviada... debes esperar la aprobación..."). Al cerrar el diálogo hace `pop(true)` para que `MyOrganizationsScreen` sepa que debe refrescar su lista de solicitudes. |
| `MyOrganizationsScreen` | `presentation/my_organizations/` — se muestra antes del shell, no tiene ruta nombrada. Antes `SelectTenantScreen`. | Gate obligatorio tras el login, **siempre** — sin importar cuántas organizaciones/solicitudes tenga el usuario, ni justo después de crear una (regla explícita: nunca ir directo al Dashboard sin selección explícita). Perfil incompleto + 0 organizaciones → `ProfileIncompleteNotice`. En cualquier otro caso: lista de organizaciones (`OrganizationCard`, o un aviso compacto si no hay ninguna) + sección **"Acciones"** persistente (Crear organización / Unirse mediante código, siempre visibles, no solo cuando no hay organizaciones) + sección **"Solicitudes"** (mis solicitudes `PENDING`/`REJECTED`, con "Cancelar" en las pendientes). Crear/Unirse ya no usan `MainShellScreen(initialPushRoute:)` — se empujan como pantallas sobre esta misma, y al volver el usuario sigue eligiendo explícitamente con qué organización continuar. Mismos dos modos que antes vía `isInitialSelection` (gate vs. cambio de organización a mitad de sesión, abierto desde `ShellHeader`/`DashboardHeaderMobile`). Ver [shell-y-navegacion.md](./shell-y-navegacion.md) y [perfil-y-usuario.md](./perfil-y-usuario.md#reglas-de-negocio). |

> **Nota:** desde ADR-012, el tab "Organizaciones" del bottom nav ya no existe (reemplazado por las 5 secciones del nuevo shell — ver [shell-y-navegacion.md](./shell-y-navegacion.md)). `TenantScreen` sigue activa y registrada, alcanzable desde los accesos rápidos del Dashboard General, pero no es uno de los 5 destinos principales del nav.

## Solicitudes de ingreso — endpoints (`/tenant`, todos requieren `Authorization: Bearer <jwt>`)

| # | Método | Ruta | Quién | Uso |
|---|---|---|---|---|
| 1 | POST | `join-tenant` | usuario | Crear solicitud (body `{tenantCode}`, ya no `userId`) |
| 2 | GET | `{id}/join-requests` | admin (`core.tenant.join_request.read`) | Listar solicitudes `PENDING` de ese tenant |
| 3 | POST | `{id}/join-requests/{requestId}/approve` | admin (`core.tenant.join_request.approve`) | Aprobar → crea la membresía real |
| 4 | POST | `{id}/join-requests/{requestId}/reject` | admin (`core.tenant.join_request.reject`) | Rechazar |
| 5 | POST | `join-requests/{requestId}/cancel` | el propio solicitante (sin `id` de tenant en la ruta) | Cancelar mi solicitud pendiente |
| 6 | GET | `join-requests/mine` | usuario | Listar **todas** mis solicitudes, cualquier estado |

Los 6 devuelven el mismo shape (`joinRequestInfo` en 1/3/4/5, `requests[]` en 2/6): `id, userId, requesterName, requesterLastName, requesterEmail, tenantId, tenantName, tenantCode, status ("PENDING"|"APPROVED"|"REJECTED"|"CANCELLED"), requestedAt, resolvedAt, resolvedByUserId`. **`requesterName`/`requesterLastName`/`requesterEmail` vienen `null` en los endpoints 5 y 6** (el backend no los enriquece ahí) — `domain/entities/join_request.dart` los modela nullable.

Modelado: `data/models/join_request_info_model.dart` → `data/mappers/join_request_mapper.dart` → `domain/entities/join_request.dart` (`JoinRequest` + `enum JoinRequestStatus`). Los endpoints 2/3/4 son los que usa la pestaña "Usuarios" de [organizacion.md](./organizacion.md) para el banner + pantalla de aprobar/rechazar.

## Estado

Sin estado propio persistente — cada pantalla lee `context.read<AuthProvider>().session` para obtener las organizaciones actuales y muta `session.hasTenant`/`user.tenants` directamente al crear (unirse ya no muta nada, ver arriba), seguido de `authProvider.refreshSession()` para propagar el cambio a quien esté escuchando (ej. el panel principal).

Controllers (vía `TenantInjection`): `RegisterTenantWithOwnerController`, `JoinTenantController`, `GetTenantUsersController`, `GetPendingJoinRequestsController`, `GetMyJoinRequestsController`, `JoinRequestActionsController` (agrupa `approve`/`reject`/`cancel` — mismo verbo, 3 variantes, en vez de 3 clases casi idénticas).

## Casos de uso relacionados

Ver [casos de uso — tenant](../00-core/04-casos-de-uso/tenant/casos-de-uso.md).

## Puntos de atención

- **`CreateTenantScreen`/`JoinTenantScreen` exigen perfil completo** (`User.isProfileComplete`, ver [perfil-y-usuario.md](./perfil-y-usuario.md#reglas-de-negocio)): si el usuario intenta crear o unirse con el perfil incompleto, ven `ProfileIncompleteNotice` en vez del formulario. Este guard vive en el destino (no en cada punto de entrada) para cubrir también al usuario que ya tiene una organización y trata de crear una segunda con el perfil incompleto — el gate de login por sí solo no puede detectar ese caso.
- El formulario de "unirse" no tiene (ni debe tener) selector de rol — el rol lo asigna el backend al aprobar (siempre `Member`). Antes de ADR-011 el frontend enviaba `"role": "MEMBER"` hardcodeado; era una escalada de privilegios latente si el backend hubiese confiado en ese valor.
- `JoinTenantScreen` abre su diálogo de éxito con `showGeneralDialog` (que por defecto usa el navigator raíz, no el interno del shell donde vive la pantalla) — el cierre del diálogo y el `pop` de la propia pantalla usan navigators capturados por separado para evitar dejar la app en una pantalla en blanco.
- La entidad `JoinTenant` (antes usada por el flujo de unirse, con un `UserTenant` embebido) se eliminó por completo — ya no puede representar la respuesta real (ya no hay `UserTenant` en la respuesta de unirse). Reemplazada por `JoinRequest`.
