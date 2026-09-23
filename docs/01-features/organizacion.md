# Feature: Organización (`lib/features/organization`)

> **Nueva en Fase 3 del rediseño de navegación (2026-07-26).** No confundir con [organizaciones.md](./organizaciones.md) (feature `tenant`, que cubre crear/unirse/listar organizaciones y seleccionar cuál está activa). `organization` es la gestión de la organización **activa**: su información, usuarios, roles y estructura. Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §3.1.
>
> **Actualización 2026-07-27 (pestaña Usuarios real):** `GET /tenant/{id}/users` ya existe — la pestaña "Usuarios" dejó de ser `ComingSoonView` y pasó a listar los miembros reales de la organización activa, con búsqueda/filtros/orden en memoria (sin paginación en el backend). También se sumaron los endpoints de solicitudes de ingreso (ver [organizaciones.md](./organizaciones.md)), así que el banner de "solicitudes pendientes" + la pantalla de aprobar/rechazar (que se habían descartado en un primer intento por no existir ese backend) sí se construyeron. Ver §"Pestañas" abajo para el detalle completo.
>
> **Actualización 2026-07-27 (navegación adaptada a Member):** `OrganizationScreen` ya no muestra siempre las mismas 4 pestañas. Un usuario Member ve Información/Estructura Organizacional/Mi membresía; solo un Admin ve Información/Usuarios/Roles/Estructura. Ver §"Navegación adaptada por rol" abajo — incluye por qué esto sigue siendo cosmético (no hay endpoint de permisos todavía) y el diseño (sin implementar) de Departamentos como segundo nivel de membresía.
>
> **Actualización 2026-07-27 (editar organización):** `PUT /tenant/{id}` ya existe (`core.tenant.update`) — la pestaña Información de Admin ganó un `floatingActionButton` ("Editar organización") que abre `EditOrganizationBottomSheet` para actualizar nombre/descripción (código y estado no se tocan desde ese endpoint). Solo visible con `OrganizationCapabilities.isAdmin`; un Member nunca lo ve. Ver §"Editar organización (Admin)" abajo.
>
> **Actualización 2026-07-27 (Estructura Organizacional real para Member):** los 3 endpoints de solicitud de ingreso a departamento (`POST /organization-units/{id}/join-requests`, `POST /organization-units/join-requests/{requestId}/cancel`, `GET /organization-units/join-requests/mine`) ya existen — la pestaña "Estructura Organizacional" de Member dejó de ser `ComingSoonView` y pasa a listar los departamentos reales del tenant (reutilizando el mismo `OrganizationUnitsProvider` que ya usa la pestaña Admin "Estructura"), con filtros/resumen/búsqueda en memoria y el ciclo de vida completo de la propia solicitud de ingreso (solicitar/cancelar/reintentar). Aprobar/rechazar solicitudes de departamento sigue sin construir (responsabilidad futura del encargado del departamento, no de este pase). Ver §"Pestaña Estructura Organizacional (Member)" abajo para el detalle completo — reemplaza la sección "Diseño futuro: Departamentos" que documentaba una forma de endpoint especulativa y ya no vigente.

## Responsabilidad

Sección "Organización" del shell — la organización activa vista como una unidad administrable (Admin) o participable (Member). "Información" y "Usuarios" ya tienen `domain`/`data` real (`Tenant`/`UserTenant`/`TenantMember`/`JoinRequest`, todos de la feature `tenant`); "Estructura Organizacional" (Member) también, sobre `OrganizationUnit`/`UnitJoinRequest` (feature `organization_unit`). Solo Roles (Admin) sigue sin backend que consultar.

## Pantallas (`presentation/organization/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `OrganizationScreen` | `AppRoutes.organization` (sección "Organización" del shell) | `Scaffold` con `TabBar` cuyo contenido depende de `OrganizationCapabilities.isAdmin` (ver abajo): Admin ve 4 pestañas (Información/Usuarios reales, Roles/Estructura placeholder); Member ve 3 (Información real, Estructura Organizacional placeholder, Mi membresía real). El `TabController` se recrea si la capacidad cambia (ej. el usuario cambia de organización activa a una donde tiene otro rol) — ver `_ensureController`. `floatingActionButton` condicional, calculado en `_buildFab`: "Editar organización" para Admin en Información, "Invitar usuario" para Admin en Usuarios, nada en cualquier otro caso (incluyendo toda la vista Member). |
| `PendingJoinRequestsScreen` | Empujada desde el banner de la pestaña Usuarios (`widgets/users/pending_join_requests_screen.dart`) | Lista de solicitudes `PENDING` del tenant activo, con Aprobar/Rechazar (cada una con diálogo de confirmación). |

## Pestañas — vista Admin

| Pestaña | ¿Backend? | Implementación |
|---|---|---|
| **Información** | Sí — `Tenant.name/description/code` vienen en `AuthProvider.session`; nombre/descripción son editables vía `PUT /tenant/{id}` (Admin) | `OrganizationInfoTab` (`widgets/`): tarjeta de solo lectura (`BaseContainerCard`, en `shared/widgets/`) con nombre, descripción, código y el rol del usuario en esa organización (informativo, ver [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md)). La propia pestaña sigue sin botones — la edición vive en el FAB de `OrganizationScreen` (ver §"Editar organización (Admin)"), así que `OrganizationInfoTab` se reutiliza sin cambios para Member (nunca ve una acción de edición). |
| **Usuarios** | Sí — `GET /tenant/{id}/users` (lista, sin paginar) + los endpoints de solicitudes de ingreso (ver [organizaciones.md](./organizaciones.md)) para el banner/pantalla de aprobar-rechazar | `widgets/users/` (ver detalle abajo) |
| **Roles** | No — ADR-011 excluye explícitamente "administración de roles (crear roles personalizados, asignar/quitar permisos, catálogo de permisos)" de su alcance | `ComingSoonView` |
| **Estructura** | No — no existe modelo de dominio para jerarquía/departamentos | `ComingSoonView` |

## Pestañas — vista Member

Un Member nunca ve Usuarios ni Roles (son capacidades administrativas — gestionar usuarios y asignar roles/permisos no le corresponden) y nunca ve la pestaña bloqueada con un candado: la navegación cambia de forma, no se oculta con un overlay.

| Pestaña | ¿Backend? | Implementación |
|---|---|---|
| **Información** | Igual que en Admin | `OrganizationInfoTab` (reutilizado) |
| **Estructura Organizacional** | Sí — `GET /organization-units` (compartido con la pestaña Admin "Estructura", mismo `OrganizationUnitsProvider`) + los 3 endpoints de solicitud de ingreso a departamento (ver §"Pestaña Estructura Organizacional (Member)" abajo) | `widgets/structure_member/` (ver detalle abajo) |
| **Mi membresía** | Parcial — usa `User`/`UserTenant` ya presentes en `AuthProvider.session` | `MembershipInfoTab` (`widgets/membership_info_tab.dart`): tarjeta de solo lectura con usuario, organización, rol (`roles.join(', ')`) y estado (`UserTenant.status`), todos reales. "Miembro desde" se muestra como "No disponible" a propósito — ningún endpoint expone fecha de ingreso todavía. La sección de departamentos se deja como nota honesta ("aparecerán aquí cuando..."), no una lista vacía sin contexto. |

`ComingSoonView` es la versión sin `Scaffold` de `ComingSoonScreen` (usada tal cual por Módulos/Administración como pantalla completa) — se extrajo específicamente para poder embeberla dentro de una pestaña de `TabBarView`.

## Editar organización (Admin)

`EditOrganizationBottomSheet` (`presentation/organization/bottom_sheets/`) — formulario de nombre/descripción, precargado con los valores actuales del tenant activo. Al guardar llama `TenantInjection.updateTenantController().updateTenant(...)` → `UpdateTenantUseCase` → `TenantRepositoryAdapter.updateTenant` → `TenantApi.updateTenant` (`PUT /tenant/{id}`, body `{name, description}`, respuesta `{ tenantInfo: {...} }`, mismo patrón de envoltorio que `POST /tenant/create-with-owner`). Requiere `core.tenant.update` en el backend — si el usuario no lo tiene, el 403 se muestra como texto de error inline en el propio formulario (`ApiException.message`), sin bloquear el resto de la pantalla.

El endpoint solo devuelve el `Tenant` actualizado, no el `User` completo (a diferencia de `update-profile`, que sí devuelve el `User` — ver `EditProfileBottomSheet`). Por eso `OrganizationScreen._openEditOrganization` reconstruye manualmente `AuthProvider.session.user` reemplazando, dentro de `tenants`, el `UserTenant` cuyo `tenant.id` matchea, y llama `AuthProvider.updateUser(...)` con ese `User` reconstruido — el resto de la sesión (roles, id de la relación, status) no cambia.

**Bug relacionado que se corrigió de paso:** `TenantSessionController.resolveActive` devolvía el objeto `UserTenant` *cacheado* en `_explicitActive` con solo verificar que su `id` siguiera existiendo en la lista nueva, en vez de devolver la instancia fresca de esa lista. Como el gate de login (`MyOrganizationsScreen`) fija `_explicitActive` en casi todas las sesiones, cualquier edición del tenant activo quedaba invisible en toda la UI (Dashboard, `OrganizationInfoTab`, `MembershipInfoTab`, `ShellHeader`, `UsersTab`) hasta cerrar y volver a abrir sesión. Ahora `resolveActive` busca por `id` dentro de la lista recibida y devuelve esa instancia, así que `auth.updateUser(...)` se refleja de inmediato en todos esos consumidores sin tocarlos uno por uno.

### Pestaña Usuarios (`widgets/users/`)

Solo administra **membresía** — nunca roles/permisos (eso es explícitamente responsabilidad de la pestaña Roles, todavía sin backend). Composición:

- **`users_tab.dart`** — carga `GetTenantUsersController` (feature `tenant`) con el tenant activo. Estados: `UsersSkeletonLoader` (carga), error (403 → "No tienes acceso..." sin reintentar; resto → mensaje + botón reintentar), vacío (ilustración + "Aún no hay miembros..." + botón Invitar), o la lista. Búsqueda (nombre/correo) y filtros/orden (`user_filters_bottom_sheet.dart`) se aplican **en memoria** sobre la lista ya cargada — el endpoint no pagina. El banner de solicitudes pendientes (`_PendingRequestsBanner`) intenta `GetPendingJoinRequestsController` en paralelo; si el usuario no es admin, el 403 se ignora en silencio y el banner simplemente no aparece (no bloquea la lista de miembros).
- **`user_card.dart`** — avatar, nombre, rol (`roles.join(', ')` o "Sin rol"), correo. Sin "Último acceso" en la card: no viene en el endpoint. Menú de 3 puntos → una sola opción, "Desasociar usuario" → confirmación → `SnackBar` honesto de "Próximamente" (no existe endpoint para desasociar todavía).
- **`user_detail_bottom_sheet.dart`** — al tocar la card. "Fecha de ingreso"/"Último acceso" se muestran como "No disponible" (no inventados). "Actividad reciente" usa el mismo estado vacío honesto que `DashboardActivityCard` del Dashboard General — no hay backend de auditoría por usuario.
- **`user_filters_bottom_sheet.dart`** — Estado (Todos/Activos, real) + Roles (chips dinámicos según lo que traiga la lista, real) + Ordenar (Nombre A-Z/Z-A reales; "Más recientes"/"Más antiguos"/"Último acceso" se muestran deshabilitados con "(sin datos aún)" — no hay ningún campo de fecha en el endpoint).
- **`invite_user_bottom_sheet.dart`** — formulario real (correo + mensaje opcional), pero "Enviar invitación" termina en `SnackBar` de "Próximamente" — no existe endpoint de invitación por correo.
- **`pending_join_requests_screen.dart`** — `GetPendingJoinRequestsController` (solo `PENDING`) + `JoinRequestActionsController.approve/reject`, cada acción con diálogo de confirmación; al resolver una solicitud, se recarga la lista (el propio endpoint ya filtra por `PENDING`, así que el ítem procesado desaparece solo).

Todos comparten `AppColors.of(context).flatCardDecoration()`/`AppSpacing`/`AppTypography`/`AppRadius`, mismo lenguaje visual que el resto del rediseño (ver [panel-principal.md](./panel-principal.md)).

## Navegación adaptada por rol

`OrganizationCapabilities` (`presentation/organization/state/organization_capabilities.dart`) es el único punto de la app que decide qué pestañas de Organización mostrar. Recibe `UserTenant.roles` del tenant activo y expone `isAdmin` (`roles` contiene `"Admin"`, case-insensitive) + getters derivados (`canManageUsers`, `canManageRoles`, `canManageOrganizationStructure`, hoy todos iguales a `isAdmin`).

**Por qué es cosmético y no un gate de autorización real:** ADR-011 es explícito — `roles` es informativo, no hay endpoint de permisos (`¿puedo hacer X?`) todavía, y cualquier lógica que hoy infiera capacidades de `roles` debe quedar aislada y marcada como aproximación reemplazable. `OrganizationCapabilities` es exactamente eso: si el backend no marca a alguien como Admin por error, o si en el futuro un tenant crea un rol personalizado con otro nombre que igual debería ver Usuarios, esta clase es el único lugar a tocar. El backend sigue siendo la única autorización real — si el usuario intenta algo sin permiso vía la API, seguirá recibiendo `403 FORBIDDEN_ERROR` independientemente de lo que esta clase decida mostrar.

`OrganizationScreen` reconstruye su `TabController` (`_ensureController`) cada vez que `isAdmin` cambia de valor — no solo al montar la pantalla — porque el usuario puede cambiar de organización activa (switcher del Dashboard) hacia un tenant donde tiene un rol distinto sin salir de la pantalla.

### Pestaña Estructura Organizacional (Member) (`widgets/structure_member/`)

Segundo nivel de membresía dentro del tenant: un Member puede pertenecer a 0+ departamentos (`OrganizationUnit`, feature `organization_unit`), y pertenecer a uno se solicita y se resuelve, igual que unirse a la organización (ver [organizaciones.md](./organizaciones.md) para el flujo equivalente a nivel tenant). Solo explora/participa — nunca crea/edita/elimina departamentos ni gestiona miembros/encargados, eso es exclusivo de la pestaña Admin "Estructura" (`widgets/structure/`, ver arriba). Composición:

- **`structure_member_tab.dart`** — carga `OrganizationUnitsProvider` (COMPARTIDO con la pestaña Admin: si cualquiera de las dos ya lo cargó para el tenant activo, la otra no repite `GET /organization-units`) + `MyUnitJoinRequestsProvider` (cache global, sin `tenantId`, de `GET /organization-units/join-requests/mine`). Resumen de 3 indicadores (Mis departamentos/Solicitudes pendientes/Departamentos disponibles), buscador y 4 chips de filtro (Todos/Mis departamentos/Disponibles/Solicitudes). La relación del usuario con cada departamento (`MemberUnitRelation`, `presentation/state/member_unit_relation.dart` de la feature `organization_unit`) se resuelve cruzando `unit.members` (membresía real, chequeada primero) contra la solicitud más reciente del usuario a esa unidad.
- **`member_department_card.dart`** — mismo chrome visual que `DepartmentCard` (Admin), pero el chip de estado es la relación del usuario (`MemberRelationStatusChip`, no `DepartmentStatusChip`) y el botón de acción cambia dinámicamente: Miembro→"Ver departamento", sin relación→"Solicitar ingreso", pendiente→"Cancelar solicitud", rechazada→"Solicitar nuevamente" (mismo endpoint que "Solicitar ingreso").
- **`member_unit_detail_screen.dart`** — al tocar la card. Info pública (descripción, cantidad de miembros, fecha de creación), encargado de solo lectura, y una card de "Estado" con las mismas 4 variantes dinámicas, reactiva a `MyUnitJoinRequestsProvider` (las acciones de solicitar/cancelar aplican el resultado en memoria vía `applyResult`, sin refetch). Sin sección de miembros ni de configuración.
- **`structure_member_summary_row.dart`**, **`member_relation_status_chip.dart`**, **`structure_member_empty_state.dart`** — piezas de UI de soporte; `StructureNoResultsState` (búsqueda sin resultados) se reutiliza tal cual de `widgets/structure/`.

Contrato real de los 3 endpoints usados (los otros 11 de `/organization-units` son del lado Admin o quedan fuera de alcance — ver nota abajo):

- `POST /organization-units/{id}/join-requests` — sin body, usuario resuelto del JWT. Respuesta `{ successfully, message, joinRequestInfo }`, `status: "PENDING"`.
- `POST /organization-units/join-requests/{requestId}/cancel` — sin body, sin `id` de unidad en la ruta (el backend valida dueño). Mismo shape, `status: "CANCELLED"`.
- `GET /organization-units/join-requests/mine` — sin parámetros. `{ successfully, message, requests: [joinRequestInfo, ...] }`, todas las solicitudes del usuario a cualquier unidad/tenant.

**Fuera de alcance de este pase** (documentado así para no reabrir la pregunta): listar solicitudes pendientes de un departamento y aprobar/rechazar (endpoints ya existen en el backend, pero son responsabilidad del encargado del departamento — sin UI en ningún lado, ni Admin ni Member) y "Salir del departamento" (sin endpoint de autobaja confirmado, distinto del `removeMember` que usa el Admin).

## Estado

`context.watch<AuthProvider>()` + `context.watch<TenantSessionController>()` en `OrganizationInfoTab`, mismo patrón que el Dashboard General — si la organización activa cambia (desde el switcher del Dashboard), esta pantalla se actualiza sola.

## Casos de uso relacionados

`OrganizationScreen` no tiene `domain`/`data` propia: los casos de uso de la pestaña Usuarios (`GetTenantUsersUseCase`, `GetPendingJoinRequestsUseCase`, `JoinRequestActionsUseCase`, `GetMyJoinRequestsUseCase`) viven en la feature `tenant` (ver [organizaciones.md](./organizaciones.md)) y se consumen vía `TenantInjection`.

## Puntos de atención

- Esta pantalla **no reemplaza** a `TenantScreen` (`tenant/presentation/tenant_list/`) — esa sigue siendo la lista de *todas* las organizaciones a las que pertenece el usuario (para crear/unirse/cambiar), mientras que `OrganizationScreen` es *una sola* organización (la activa) vista en detalle.
- Invitar por correo y desasociar un miembro siguen sin backend — ambas acciones existen en la UI (formulario/confirmación reales) pero terminan en un `SnackBar` honesto de "Próximamente" en vez de una llamada real, a propósito: nunca un no-op silencioso.
- Cuando el backend exponga endpoints para roles/estructura, esas pestañas placeholder deberían ganar su propio `domain`/`data` (probablemente conviene entonces sí separarlas en subcarpetas `presentation/<pestaña>/` independientes en vez de vivir juntas en `organization/presentation/organization/widgets/`) — se mantienen juntas por ahora porque no hay lógica que justifique la separación.
- `OrganizationCapabilities.isAdmin` solo reconoce el rol literal `"Admin"` (case-insensitive) porque es el único nombre de rol admin que documenta ADR-011 hoy. Si el backend introduce roles personalizados con más capacidades, este es el lugar a revisar — ver §"Navegación adaptada por rol".
