# Feature: Organización (`lib/features/organization`)

> **Nueva en Fase 3 del rediseño de navegación (2026-07-26).** No confundir con [organizaciones.md](./organizaciones.md) (feature `tenant`, que cubre crear/unirse/listar organizaciones y seleccionar cuál está activa). `organization` es la gestión de la organización **activa**: su información, usuarios, roles y estructura. Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §3.1.

## Responsabilidad

Sección "Organización" del shell — la organización activa vista como una unidad administrable, con 4 sub-áreas (Información/Usuarios/Roles/Estructura). Sin `domain`/`data` propia: "Información" solo lee datos que ya llegan en la sesión (`Tenant`/`UserTenant` de la feature `tenant`/`auth`); las otras 3 no tienen backend que consultar todavía, así que no hay nada que modelar.

## Pantallas (`presentation/organization/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `OrganizationScreen` | `AppRoutes.organization` (sección "Organización" del shell) | `Scaffold` con `TabBar` de 4 pestañas: Información (real), Usuarios/Roles/Estructura (placeholder) |

## Pestañas

| Pestaña | ¿Backend? | Implementación |
|---|---|---|
| **Información** | Parcial — `Tenant.name/description/code` ya están en `AuthProvider.session` | `OrganizationInfoTab` (`widgets/`): tarjeta de solo lectura (`BaseContainerCard`, movida a `shared/widgets/` en esta fase por ser la primera vez que 2 features la necesitan) con nombre, descripción, código y el rol del usuario en esa organización (informativo, ver [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md)). Sin edición — no hay endpoint de actualización, y el aviso de "solo lectura" lo dice explícitamente en la propia pantalla. |
| **Usuarios** | No — `TenantApi` solo expone `createTenantWithOwner`/`joinTenant`, nada para listar miembros | `ComingSoonView` (`shared/layouts/coming_soon_screen.dart`) |
| **Roles** | No — ADR-011 excluye explícitamente "administración de roles (crear roles personalizados, asignar/quitar permisos, catálogo de permisos)" de su alcance | `ComingSoonView` |
| **Estructura** | No — no existe modelo de dominio para jerarquía/departamentos | `ComingSoonView` |

`ComingSoonView` es la versión sin `Scaffold` de `ComingSoonScreen` (usada tal cual por Módulos/Administración como pantalla completa) — se extrajo en esta fase específicamente para poder embeberla dentro de una pestaña de `TabBarView`.

## Estado

`context.watch<AuthProvider>()` + `context.watch<TenantSessionController>()` en `OrganizationInfoTab`, mismo patrón que el Dashboard General — si la organización activa cambia (desde el switcher del Dashboard), esta pantalla se actualiza sola.

## Casos de uso relacionados

Ninguno propio todavía — reutiliza los datos ya cargados por `auth`/`tenant`, no ejecuta ninguna llamada nueva al backend.

## Puntos de atención

- Esta pantalla **no reemplaza** a `TenantScreen` (`tenant/presentation/tenant_list/`) — esa sigue siendo la lista de *todas* las organizaciones a las que pertenece el usuario (para crear/unirse/cambiar), mientras que `OrganizationScreen` es *una sola* organización (la activa) vista en detalle.
- Cuando el backend exponga endpoints para miembros/roles/estructura, cada pestaña placeholder debería ganar su propio `domain`/`data` (probablemente conviene entonces sí separarlas en subcarpetas `presentation/<pestaña>/` independientes en vez de vivir juntas en `organization/presentation/organization/widgets/`) — se mantienen juntas por ahora porque no hay lógica que justifique la separación.
