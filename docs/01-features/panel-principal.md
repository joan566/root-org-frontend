# Feature: Panel Principal / Dashboard (`lib/features/dashboard`)

> **Actualización 2026-07-26 (Fase 2 del rediseño de navegación):** `PersonalDashboardScreen` se renombró/evolucionó a `DashboardGeneralScreen` (carpeta `presentation/personal_dashboard/` → `presentation/dashboard_general/`). Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §2 y [shell-y-navegacion.md](./shell-y-navegacion.md).

## Responsabilidad

Centro de control de la organización activa tras el login: organización activa (con acción para cambiarla), resumen del estado de la cuenta, checklist de primeros pasos, accesos rápidos, módulos disponibles y actividad reciente. No tiene capa `domain`/`data` propia — es puramente `presentation`, consumidor de `AuthProvider` (feature `auth`), `TenantSessionController` (`core/session/`) y de las rutas de `tenant`.

## Pantallas (`presentation/<screen>/`)

| Pantalla | Estado | Descripción |
|---|---|---|
| `DashboardGeneralScreen` | **Activa**, `AppRoutes.dashboard` (`initialRoute` del navigator interno de `MainShellScreen`) | Panel real, conectado a `AuthProvider` y `TenantSessionController` |

> `AdminDashboardPage`/`MemberDashboardPage` (mockups estáticos, no enrutados) se eliminaron en ADR-012 (ver [ADR-012-plan-migracion.md](../00-core/07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)) — el dashboard de miembro/admin diferenciado por rol sigue sin construirse; hoy hay un único `DashboardGeneralScreen` para todos los roles.

## `DashboardGeneralScreen` — composición (`presentation/dashboard_general/widgets/`)

`PremiumGradientHeader` + `HeaderUserBlock` (nombre real del usuario, chip de la organización activa — tocable para cambiarla si el usuario pertenece a 2+), luego (según `hasOrganizations`):
- **Sin organizaciones**: `NoActiveOrganizationView` con acciones para crear/unirse.
- **Con organizaciones**: `MainDashboardFeed` (recomendaciones inteligentes, actividad reciente, `UpcomingModulesSection`, `RecentOrganizationsList`) + `SideControlPanel` (checklist de primeros pasos, `MetricsSummaryBlock`, seguridad, actividad).

### Organización activa

`DashboardGeneralScreen` resuelve la organización activa con `context.watch<TenantSessionController>().resolveActive(tenantsList)` — ya no toma `tenantsList.first` a ciegas (bug real señalado en [frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §1, corregido en Fase 2). El chip de organización en `HeaderUserBlock` abre `SelectTenantScreen(isInitialSelection: false)` (`features/tenant/presentation/select_tenant/`) como una pantalla empujada sobre el navigator interno del shell, con botón de retroceso; al elegir una organización distinta, hace `pop()` en vez de reemplazar la pila — el dashboard ya escucha `TenantSessionController` y se actualiza solo. `RecentOrganizationsList` ofrece el mismo cambio de organización tocando cualquier fila que no sea la activa.

### Módulos

`UpcomingModulesSection` muestra los módulos reales del mapa de navegación (Gestión Financiera, Gestión de Préstamos, Inventario, Actividades) — ninguno tiene backend hoy, así que las 4 tarjetas son honestas ("Próximamente") y navegan a `AppRoutes.modules` (el mismo placeholder genérico del shell). No inventan badges de disponibilidad como la versión anterior.

## El drawer se eliminó (Fase 2)

`PersonalDashboardScreen` tenía un `Drawer` (Dashboard/Organizaciones/Mi Perfil/Cerrar sesión) que resultó ser **código muerto**: el `Scaffold` no tenía `AppBar`, por lo que Flutter nunca renderizaba el botón hamburguesa automático, y nada más llamaba `_scaffoldKey.currentState?.openDrawer()`. Era inalcanzable desde la UI. Se eliminó junto con `_buildProfessionalDrawer`/`_drawerItem` — la navegación equivalente ya la cubre el shell (sidebar/bottom nav) y `LogoutCard` en `ProfileScreen`.

## Estado

`context.watch<AuthProvider>()` y `context.watch<TenantSessionController>()` — el dashboard se actualiza en vivo con `AuthProvider.notifyListeners()` (de ahí la importancia de `refreshSession()` al crear/unirse a una organización) y con cualquier cambio de organización activa.

## Puntos de atención

- El grid de métricas mostraba antes una tarjeta "Permisos globales" calculada como `role == 'ADMIN' ? 15 : 5` — un número inventado a partir del nombre del rol. Se eliminó como parte del refactor de [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md), porque el frontend no debe inferir capacidades desde `roles`. El mismo criterio se aplicó en Fase 2 a `activeModules`: antes hardcodeado a `4` (otro número inventado), ahora `0` (honesto — ningún módulo tiene backend todavía).
- `AdminDashboardPage`/`MemberDashboardPage` **no deben confundirse con funcionalidad activa** — no aparecen en `AppRoutes`, no se navegan desde ningún botón, y no hay forma de llegar a ellas desde la UI actual.
