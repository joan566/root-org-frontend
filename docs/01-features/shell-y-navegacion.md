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

Módulos y Administración no tienen backend/dominio propio hoy (ver [frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §1). Sus rutas se registran directamente en `shell/presentation/shell_routes.dart`, apuntando a `ComingSoonScreen` (`shared/layouts/coming_soon_screen.dart`) — un placeholder reutilizable que explica qué falta y por qué, en vez de crear features vacías por adelantado.

**Fase 4 (2026-07-26):** se reservaron los directorios `lib/features/{financial_management,inventory,activities,administration,settings}/presentation/.gitkeep` — mismo patrón que las carpetas de `core/design_system/` que ADR-012 dejó reservadas (ver [ADR-012-plan-migracion.md](../00-core/07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)). **No tienen pantalla, ruta ni ningún código todavía** — a diferencia de Organización (Fase 3), que sí ganó una feature real porque su pestaña "Información" tenía datos existentes que mostrar; ninguno de estos 5 tiene ni eso. `AppRoutes.modules`/`AppRoutes.administration` siguen sirviendo el `ComingSoonScreen` genérico de Fase 1 sin cambios. Cuando alguno de estos módulos tenga trabajo real (backend + necesidad de UI propia), su propio `<feature>_routes.dart` reemplaza la entrada correspondiente en `shell_routes.dart` — mismo mecanismo ya usado para Organización.

## Selección de organización activa

`TenantSessionController` (`core/session/tenant_session_controller.dart`) recuerda cuál `UserTenant` está activo durante la sesión — es aditivo, no modifica `AuthProvider`/`LoginSesion`. `MainApp` (`main.dart`) decide entre `LoginScreen`/`SelectTenantScreen`/`MainShellScreen` con 3 ramas:

```dart
if (!auth.isLogged) home = const LoginScreen();
else if (!tenantSession.hasPassedGate) home = const SelectTenantScreen();
else home = const MainShellScreen();
```

**Actualizado (Fase 5, 2026-07-26):** `SelectTenantScreen` (modo inicial) ahora es un **gate obligatorio** — se muestra siempre tras el login, sin importar cuántas organizaciones tenga el usuario (antes solo aparecía con 2+; con 0 o 1 se entraba directo). `hasPassedGate` es un flag nuevo en `TenantSessionController`, independiente de `resolveActive()` (que sigue autoseleccionando con 1 organización para el resto de la app — dashboard, organización, etc. — solo el gate de login exige confirmación explícita incluso con una sola). `clear()` resetea `hasPassedGate` al cerrar sesión.

`SelectTenantScreen` tiene dos modos, controlados por `isInitialSelection` (default `true`):
- **Inicial** (login, sin sesión de shell todavía) — 3 estados según los datos reales:
  1. Perfil incompleto (`!user.isProfileComplete`) → `ProfileIncompleteNotice` (ver [perfil-y-usuario.md](./perfil-y-usuario.md#reglas-de-negocio)).
  2. Perfil completo, 0 organizaciones → reutiliza `NoActiveOrganizationView` (ver [panel-principal.md](./panel-principal.md)).
  3. 1+ organizaciones → lista (`OrganizationCard`), con confirmación explícita incluso con una sola.

  Cualquiera de los 3 entra al shell vía el helper `_enterShell`, que llama `markGatePassed()` y hace `Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => MainShellScreen(initialPushRoute: ...)), (route) => false)` — con `initialPushRoute` opcional (`AppRoutes.profile`/`createTenant`/`joinTenant`) para aterrizar directo en esa pantalla en vez del dashboard.
- **Cambio a mitad de sesión** (`isInitialSelection: false`, abierta desde el chip de organización en `HeaderUserBlock` del Dashboard General — ver [panel-principal.md](./panel-principal.md), solo cuando el usuario ya tiene 2+): con `AppBar`/botón de retroceso, sin "Cerrar sesión"; al elegir, solo hace `pop()` — se empujó sobre el navigator interno del shell, así que el Dashboard (que ya escucha `TenantSessionController`) se actualiza solo al volver.

### `MainShellScreen(initialPushRoute:)`

Parámetro opcional nuevo en `MainShellScreen`: en `initState`, si viene seteado, hace `addPostFrameCallback` y empuja esa ruta con nombre sobre `AppRoutes.dashboard` (la ruta inicial de siempre) en el `Navigator` interno. El dashboard queda debajo en la pila, así que el botón atrás regresa ahí con normalidad, y pantallas como `CreateTenantScreen`/`ProfileScreen` funcionan sin ningún cambio — siguen resolviendo contra el mismo `Navigator` interno de siempre, sin importar si llegaron ahí por un acceso rápido normal o por este mecanismo.

### Logout — fix de un bug preexistente

`SelectTenantScreen._enterShell` entra al shell con `pushAndRemoveUntil(..., (route) => false)`, lo que elimina permanentemente la ruta `"/"` del historial del Navigator raíz. Antes de esta fase, `LogoutCard` (`ProfileScreen`) y `SelectTenantScreen._logout` cerraban sesión sin ningún `Navigator` explícito, confiando en que `MaterialApp.home` reactivo regresara a `LoginScreen` — eso solo funciona mientras `"/"` siga en el historial, así que el logout ya estaba roto (bug preexistente) para cualquier usuario que hubiera pasado por el flujo de 2+ organizaciones. Como esta fase hace que **todo** login pase por ese mismo mecanismo (incluso con 1 organización), se corrigió en los 2 call sites agregando el mismo patrón que ya usa `_enterShell`:

```dart
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
```

Al cerrar sesión (`LogoutCard` en `ProfileScreen`, o desde `SelectTenantScreen` inicial) se llama `TenantSessionController.clear()` además de `AuthProvider.logout()`, para no arrastrar la organización activa a la siguiente sesión.

**Segundo bug relacionado, encontrado tras el anterior:** con el logout ya arreglado, iniciar sesión, cerrar sesión, y volver a iniciar sesión dejaba al usuario atascado en `LoginScreen` sin avanzar. Causa: `LoginScreen._login()` nunca navegaba explícitamente tras un login exitoso — dependía del mismo mecanismo reactivo de `MaterialApp.home`, que solo reacciona mientras la app sigue en la ruta `"/"` del Navigator raíz. El fix de logout de arriba hace que **todo** logout saque a `"/"` del historial permanentemente (antes solo pasaba con 2+ organizaciones); una vez ahí, ningún login subsiguiente tenía a quién notificar. Se corrigió agregando el mismo patrón en `LoginScreen._login()`, apuntando siempre a `SelectTenantScreen` (el gate es el destino correcto tras cualquier login):

```dart
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const SelectTenantScreen()),
  (route) => false,
);
```

## Widgets

- `AppBackButton`/`HeaderClipper` (`shared/widgets/`): sin cambios.
- `ShellSidebar`/`ShellBottomNav`/`ShellSection` (`presentation/widgets/`): nuevos, exclusivos de `shell/`.

## Puntos de atención

- El bottom nav mobile es **solo íconos** (con `Tooltip` por accesibilidad) — se probó con labels visibles (siempre, y luego solo en el ítem activo) y ambas variantes truncaban texto en anchos móviles típicos (~390px / 5 secciones ≈ 78px por ítem); "Organización"/"Administración" no entran en ese espacio con ningún tamaño de fuente razonable.
- Diálogos abiertos con `showGeneralDialog`/`showDialog` desde una pantalla que vive en el navigator interno se montan, por defecto, en el navigator **raíz** (`useRootNavigator: true`) — mismo cuidado que antes, ver el caso de `JoinTenantScreen` en [organizaciones.md](./organizaciones.md).
- El filtrado de navegación por rol (mencionado en la propuesta original) **no se implementó en esta fase** — ver "Puntos abiertos" en [frontend-navigation-redesign.md](../frontend-navigation-redesign.md).
