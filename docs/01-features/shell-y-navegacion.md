# Feature: Shell y Navegación (`lib/features/shell`)

> **Actualización 2026-07-26 (Fase 1 del rediseño de navegación):** `MainLayout` (bottom nav fijo de 4 posiciones) se reemplazó por `MainShellScreen` (sidebar en Desktop, bottom nav adaptativa en Mobile, 5 secciones). Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) para el diseño completo y los hallazgos de backend que lo motivaron.

## Responsabilidad

El layout de la app una vez autenticado: navegación principal (sidebar/bottom nav según ancho), y el navigator interno que resuelve todas las pantallas autenticadas. No contiene lógica de negocio — es infraestructura de navegación y composición visual.

## `MainShellScreen` (`presentation/pages/main_shell_screen.dart`)

- `Breakpoints.isDesktopContext(context)` decide el layout: en Desktop, `Row(ShellSidebar + Expanded(Navigator))`; en Mobile, `Scaffold(body: Navigator, bottomNavigationBar: ShellBottomNav)`.
- 5 secciones principales (`ShellSection`, `presentation/widgets/shell_section.dart`): Dashboard, Organización, Módulos, Administración, Configuración. Cada una declara su `route` y, opcionalmente, `relatedRoutes` (rutas adicionales que deben mantener esa sección resaltada — ej. Configuración cubre también `changePassword`).
- Contiene un `Navigator` propio (`_innerNavigatorKey`), con `initialRoute: AppRoutes.dashboard` y `onGenerateRoute` resuelto contra `RouteRegistry.instance` (`core/routing/route_registry.dart`) — **ya no es un switch manual**: cada feature registra sus propias rutas en su archivo `<feature>_routes.dart`, llamado una vez desde `core/routing/register_all_routes.dart` al iniciar la app. Ver [03-arquitectura-navegacion.md](../00-core/07-refactor-arquitectura-frontend/03-arquitectura-navegacion.md) §3.1 (el shell ya no necesita conocer las pantallas de cada feature).
- Un `NavigatorObserver` interno (`_InnerRouteObserver`) escucha los cambios de ruta de ese navigator y sincroniza el índice resaltado del sidebar/bottom nav, comparando contra `ShellSection.matchesRoute`.
- `PopScope(canPop: false, ...)` intercepta el botón de retroceso del sistema para delegarlo al navigator interno — sin cambios respecto a `MainLayout`.
- **El FAB de "crear organización" se eliminó** (acoplamiento ya señalado como deuda en la versión anterior de este documento — no escalaba a otros módulos). Crear/unirse a una organización sigue disponible desde el Dashboard General y desde `TenantScreen`.

## Secciones sin feature propia todavía

Módulos y Administración no tienen backend/dominio propio hoy (ver [frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §1). Sus rutas se registran directamente en `shell/presentation/shell_routes.dart`, apuntando a `ComingSoonScreen` (`shared/layouts/coming_soon_screen.dart`) — un placeholder reutilizable que explica qué falta y por qué, en vez de crear features vacías por adelantado. Cuando cada una tenga su propia feature (Fase 4 para los módulos), su propio `<feature>_routes.dart` reemplaza esa entrada — mismo patrón que ya se aplicó a Organización en la Fase 3 (ver [organizacion.md](./organizacion.md)).

## Selección de organización activa

**Nuevo:** `TenantSessionController` (`core/session/tenant_session_controller.dart`) recuerda cuál `UserTenant` está activo durante la sesión — es aditivo, no modifica `AuthProvider`/`LoginSesion`. `MainApp` (`main.dart`) decide entre `LoginScreen`/`SelectTenantScreen`/`MainShellScreen` según `auth.isLogged` y `tenantSession.resolveActive(tenants)`:

- 0 organizaciones o 1 organización → se resuelve automáticamente, entra directo a `MainShellScreen`.
- 2+ organizaciones sin elección explícita → `SelectTenantScreen` (`features/tenant/presentation/select_tenant/`), reutiliza `OrganizationCard`.

`SelectTenantScreen` tiene dos modos, controlados por `isInitialSelection` (default `true`):
- **Inicial** (login, sin sesión de shell todavía): sin `AppBar`, con botón "Cerrar sesión"; al elegir, `pushAndRemoveUntil` reemplaza toda la pila por un `MainShellScreen` nuevo — mismo comportamiento que si acabara de iniciar sesión.
- **Cambio a mitad de sesión** (`isInitialSelection: false`, abierta desde el chip de organización en `HeaderUserBlock` del Dashboard General — ver [panel-principal.md](./panel-principal.md)): con `AppBar`/botón de retroceso, sin "Cerrar sesión"; al elegir, solo hace `pop()` — se empujó sobre el navigator interno del shell, así que el Dashboard (que ya escucha `TenantSessionController`) se actualiza solo al volver.

Al cerrar sesión (`LogoutCard` en `ProfileScreen`, o desde `SelectTenantScreen` inicial) se llama `TenantSessionController.clear()` además de `AuthProvider.logout()`, para no arrastrar la organización activa a la siguiente sesión.

## Widgets

- `AppBackButton`/`HeaderClipper` (`shared/widgets/`): sin cambios.
- `ShellSidebar`/`ShellBottomNav`/`ShellSection` (`presentation/widgets/`): nuevos, exclusivos de `shell/`.

## Puntos de atención

- El bottom nav mobile es **solo íconos** (con `Tooltip` por accesibilidad) — se probó con labels visibles (siempre, y luego solo en el ítem activo) y ambas variantes truncaban texto en anchos móviles típicos (~390px / 5 secciones ≈ 78px por ítem); "Organización"/"Administración" no entran en ese espacio con ningún tamaño de fuente razonable.
- Diálogos abiertos con `showGeneralDialog`/`showDialog` desde una pantalla que vive en el navigator interno se montan, por defecto, en el navigator **raíz** (`useRootNavigator: true`) — mismo cuidado que antes, ver el caso de `JoinTenantScreen` en [organizaciones.md](./organizaciones.md).
- El filtrado de navegación por rol (mencionado en la propuesta original) **no se implementó en esta fase** — ver "Puntos abiertos" en [frontend-navigation-redesign.md](../frontend-navigation-redesign.md).
