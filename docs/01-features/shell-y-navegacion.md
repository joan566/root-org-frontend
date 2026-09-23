# Feature: Shell y Navegación (`lib/features/shell`)

> **Actualización 2026-07-26 (Fase 1 del rediseño de navegación):** `MainLayout` (bottom nav fijo de 4 posiciones) se reemplazó por `MainShellScreen` (sidebar en Desktop, bottom nav adaptativa en Mobile, 5 secciones). Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) para el diseño completo y los hallazgos de backend que lo motivaron.

## Responsabilidad

El layout de la app una vez autenticado: navegación principal (sidebar/bottom nav según ancho), y el navigator interno que resuelve todas las pantallas autenticadas. No contiene lógica de negocio — es infraestructura de navegación y composición visual.

## `MainShellScreen` (`presentation/pages/main_shell_screen.dart`)

- `Breakpoints.isDesktopContext(context)` decide el layout: en Desktop, `Column(ShellHeader + Expanded(Row(ShellSidebar + Expanded(Navigator))))`; en Mobile, `Scaffold(body: Navigator, bottomNavigationBar: ShellBottomNav)` — sin cambios en mobile, `ShellHeader` es exclusivo de Desktop (ver "Rediseño visual SaaS premium" más abajo).
- 5 secciones principales (`ShellSection`, `presentation/widgets/shell_section.dart`): Dashboard, Organización, Módulos, Administración, Configuración. Cada una declara su `route` y, opcionalmente, `relatedRoutes` (rutas adicionales que deben mantener esa sección resaltada — ej. Configuración cubre también `changePassword`).
- Contiene un `Navigator` propio (`_innerNavigatorKey`), con `initialRoute: AppRoutes.dashboard` y `onGenerateRoute` resuelto contra `RouteRegistry.instance` (`core/routing/route_registry.dart`) — **ya no es un switch manual**: cada feature registra sus propias rutas en su archivo `<feature>_routes.dart`, llamado una vez desde `core/routing/register_all_routes.dart` al iniciar la app. Ver [03-arquitectura-navegacion.md](../00-core/07-refactor-arquitectura-frontend/03-arquitectura-navegacion.md) §3.1 (el shell ya no necesita conocer las pantallas de cada feature).
- Un `NavigatorObserver` interno (`_InnerRouteObserver`) escucha los cambios de ruta de ese navigator y sincroniza el índice resaltado del sidebar/bottom nav, comparando contra `ShellSection.matchesRoute`.
- `PopScope(canPop: false, ...)` intercepta el botón de retroceso del sistema para delegarlo al navigator interno — sin cambios respecto a `MainLayout`.
- **El FAB de "crear organización" se eliminó** (acoplamiento ya señalado como deuda en la versión anterior de este documento — no escalaba a otros módulos). Crear/unirse a una organización sigue disponible desde el Dashboard General y desde `TenantScreen`.

## Secciones sin feature propia todavía

Módulos y Administración no tienen backend/dominio propio hoy (ver [frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §1). Sus rutas se registran directamente en `shell/presentation/shell_routes.dart`, apuntando a `ComingSoonScreen` (`shared/layouts/coming_soon_screen.dart`) — un placeholder reutilizable que explica qué falta y por qué, en vez de crear features vacías por adelantado.

**Fase 4 (2026-07-26):** se reservaron los directorios `lib/features/{financial_management,inventory,activities,administration,settings}/presentation/.gitkeep` — mismo patrón que las carpetas de `core/design_system/` que ADR-012 dejó reservadas (ver [ADR-012-plan-migracion.md](../00-core/07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)). **No tienen pantalla, ruta ni ningún código todavía** — a diferencia de Organización (Fase 3), que sí ganó una feature real porque su pestaña "Información" tenía datos existentes que mostrar; ninguno de estos 5 tiene ni eso. `AppRoutes.modules`/`AppRoutes.administration` siguen sirviendo el `ComingSoonScreen` genérico de Fase 1 sin cambios. Cuando alguno de estos módulos tenga trabajo real (backend + necesidad de UI propia), su propio `<feature>_routes.dart` reemplaza la entrada correspondiente en `shell_routes.dart` — mismo mecanismo ya usado para Organización.

## Selección de organización activa

`TenantSessionController` (`core/session/tenant_session_controller.dart`) recuerda cuál `UserTenant` está activo durante la sesión — es aditivo, no modifica `AuthProvider`/`LoginSesion`. `MainApp` (`main.dart`) decide entre `LoginScreen`/`MyOrganizationsScreen`/`MainShellScreen` con 3 ramas:

```dart
if (!auth.isLogged) home = const LoginScreen();
else if (!tenantSession.hasPassedGate) home = const MyOrganizationsScreen();
else home = const MainShellScreen();
```

**Actualizado (Fase 5, 2026-07-26):** `MyOrganizationsScreen` (modo inicial) ahora es un **gate obligatorio** — se muestra siempre tras el login, sin importar cuántas organizaciones tenga el usuario (antes solo aparecía con 2+; con 0 o 1 se entraba directo). `hasPassedGate` es un flag nuevo en `TenantSessionController`, independiente de `resolveActive()` (que sigue autoseleccionando con 1 organización para el resto de la app — dashboard, organización, etc. — solo el gate de login exige confirmación explícita incluso con una sola). `clear()` resetea `hasPassedGate` al cerrar sesión.

**Actualizado (2026-07-27, evolución a "Mis Organizaciones"):** antes `SelectTenantScreen` — mismo rol de gate, pero ya no es solo un selector: ver [organizaciones.md](./organizaciones.md) para el detalle completo (secciones "Acciones"/"Solicitudes" persistentes, unirse por código ahora crea una solicitud en vez de membresía instantánea). La regla del gate se hizo **más estricta**: ni crear una organización ni enviar una solicitud de ingreso llevan ya directo al Dashboard — ambas se empujan sobre esta misma pantalla, y `_enterShell(initialPushRoute:)` quedó reservado solo para "completar perfil" (que sí es un prerrequisito, no una organización).

`MyOrganizationsScreen` tiene dos modos, controlados por `isInitialSelection` (default `true`):
- **Inicial** (login, sin sesión de shell todavía):
  1. Perfil incompleto **y** 0 organizaciones → `ProfileIncompleteNotice` (ver [perfil-y-usuario.md](./perfil-y-usuario.md#reglas-de-negocio)) — único caso que toma toda la pantalla; entra al shell vía `_enterShell(initialPushRoute: AppRoutes.profile)`.
  2. Cualquier otro caso (0, 1 o 2+ organizaciones, con o sin solicitudes) → organizaciones (lista `OrganizationCard`, o un aviso compacto si no hay ninguna) + sección "Acciones" persistente + sección "Solicitudes" si aplica. Elegir una organización sigue entrando al shell vía `_enterShell(context)` (sin `initialPushRoute`) — la única acción que de verdad selecciona un tenant activo.
- **Cambio a mitad de sesión** (`isInitialSelection: false`, abierta desde `ShellHeader`/`DashboardHeaderMobile`, solo cuando el usuario ya tiene 2+ organizaciones): con `AppBar`/botón de retroceso, sin "Cerrar sesión"; al elegir una organización, solo hace `pop()` — se empujó sobre el navigator interno del shell, así que el Dashboard (que ya escucha `TenantSessionController`) se actualiza solo al volver. Mismas secciones "Acciones"/"Solicitudes" también visibles aquí.

### `MainShellScreen(initialPushRoute:)`

Parámetro opcional nuevo en `MainShellScreen`: en `initState`, si viene seteado, hace `addPostFrameCallback` y empuja esa ruta con nombre sobre `AppRoutes.dashboard` (la ruta inicial de siempre) en el `Navigator` interno. El dashboard queda debajo en la pila, así que el botón atrás regresa ahí con normalidad, y pantallas como `CreateTenantScreen`/`ProfileScreen` funcionan sin ningún cambio — siguen resolviendo contra el mismo `Navigator` interno de siempre, sin importar si llegaron ahí por un acceso rápido normal o por este mecanismo.

### Logout — fix de un bug preexistente

`MyOrganizationsScreen._enterShell` entra al shell con `pushAndRemoveUntil(..., (route) => false)`, lo que elimina permanentemente la ruta `"/"` del historial del Navigator raíz. Antes de esta fase, `LogoutCard` (`ProfileScreen`) y `MyOrganizationsScreen._logout` cerraban sesión sin ningún `Navigator` explícito, confiando en que `MaterialApp.home` reactivo regresara a `LoginScreen` — eso solo funciona mientras `"/"` siga en el historial, así que el logout ya estaba roto (bug preexistente) para cualquier usuario que hubiera pasado por el flujo de 2+ organizaciones. Como esta fase hace que **todo** login pase por ese mismo mecanismo (incluso con 1 organización), se corrigió en los 2 call sites agregando el mismo patrón que ya usa `_enterShell`:

```dart
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
```

Al cerrar sesión (`LogoutCard` en `ProfileScreen`, o desde `MyOrganizationsScreen` inicial) se llama `TenantSessionController.clear()` además de `AuthProvider.logout()`, para no arrastrar la organización activa a la siguiente sesión.

**Segundo bug relacionado, encontrado tras el anterior:** con el logout ya arreglado, iniciar sesión, cerrar sesión, y volver a iniciar sesión dejaba al usuario atascado en `LoginScreen` sin avanzar. Causa: `LoginScreen._login()` nunca navegaba explícitamente tras un login exitoso — dependía del mismo mecanismo reactivo de `MaterialApp.home`, que solo reacciona mientras la app sigue en la ruta `"/"` del Navigator raíz. El fix de logout de arriba hace que **todo** logout saque a `"/"` del historial permanentemente (antes solo pasaba con 2+ organizaciones); una vez ahí, ningún login subsiguiente tenía a quién notificar. Se corrigió agregando el mismo patrón en `LoginScreen._login()`, apuntando siempre a `MyOrganizationsScreen` (el gate es el destino correcto tras cualquier login):

```dart
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const MyOrganizationsScreen()),
  (route) => false,
);
```

## Rediseño visual SaaS premium (2026-07-26, Desktop)

Junto con el rediseño del [Dashboard General desktop](./panel-principal.md#vista-desktop-presentationdashboard_generaldesktop), el shell ganó dos cambios visuales, ambos exclusivos de la rama Desktop (`Breakpoints.isDesktopContext`) — mobile (bottom nav) no se tocó:

- **`ShellSidebar`**: ancho `260px` → `240px`. El ítem activo, además del fondo tenue que ya tenía, gana una barra vertical azul de 3px en el borde izquierdo (estilo Notion/Linear). Los íconos de `_sections` (definidos en `main_shell_screen.dart`) pasan de variantes rellenas (`_rounded`) a outline (`_outlined`) — esto también afecta al bottom nav mobile (comparten la misma lista `_sections`), un cambio cosmético menor y deliberadamente aceptado por consistencia visual entre breakpoints.
- **`widgets/shell_header.dart`** (nuevo): header de 80px que antes no existía a nivel shell — el único header vivía dentro de `DashboardGeneralScreen` (`HeaderUserBlock`, que sigue existiendo para mobile/tablet). Se lee directamente de `AuthProvider`/`TenantSessionController` (mismo patrón que otros widgets del árbol autenticado). Contiene: logo + nombre de la organización activa + badge "Activa" (real, `UserTenant.status`); un buscador decorativo **no funcional** (`TextField` deshabilitado, sin backend — mismo criterio honesto que `UpcomingModulesSection`); íconos de notificaciones/mensajes también decorativos, sin contador inventado; el selector de organización (mismo destino que el chip de `HeaderUserBlock`: `MyOrganizationsScreen(isInitialSelection: false)`, solo visible con 2+ organizaciones); y avatar + nombre + rol activo.

Esto también implicó el cambio de paleta global (`AppPalette`, ver [ADR-013](../00-core/08-theming/ADR-013-modo-oscuro.md)): color primario de verde (`#10B981`) a azul (`#2563EB`), más un token nuevo `secondary` (`#4F46E5`) y un `flatCardDecoration()` (tarjeta blanca plana, sin gradiente) — afecta a toda la app, no solo al shell/dashboard.

### 2ª iteración visual (2026-07-26): sidebar colapsable + submenú de Módulos

`ShellSidebar` pasó de `StatelessWidget` a `StatefulWidget` para soportar dos estados locales, ambos exclusivos de Desktop:

- **Colapsar/expandir**: botón `chevron_left`/`chevron_right` al pie del sidebar, anima el ancho entre `240px` (expandido) y `76px` (colapsado, solo iconos) con `AnimatedContainer`. El label de texto y la barra de acento de 3px **no se renderizan** en absoluto cuando está colapsado (no solo se ocultan con opacidad) — así el árbol de widgets ya es icon-only *antes* de que empiece la animación de ancho, evitando que un `RenderFlex` intente encajar texto en un ancho que todavía se está encogiendo (ver overflow real detectado y corregido en la primera pasada, abajo). Cada ítem colapsado envuelve el icono en un `Tooltip` con el label, por accesibilidad.
- **Submenú de "Módulos"**: un chevron (`_ExpandChevron`, con `AnimatedRotation`) a la derecha del ítem "Módulos" — solo visible expandido — despliega 4 subitems (Gestión Financiera, Inventario, Actividades, Gestión de Préstamos, mismo set/orden que las tarjetas del dashboard). Los 4 navegan hoy a la misma `AppRoutes.modules` (ningún módulo tiene ruta propia todavía — mismo criterio que las tarjetas del dashboard general).

**Overflow real encontrado y corregido en esta iteración** (reproducido con un widget test pumpeando `MainShellScreen` a varios anchos y capturando `FlutterError.onError`, no son falsos positivos de la fuente de fallback de `flutter test`):
- El label del ítem de sidebar (`Text(section.label)`) nunca estaba envuelto en `Expanded` — al reducir el ancho de `260px` a `240px` y agregar la barra de acento de 3px, labels largos ("Administración", "Configuración") desbordaban 30-59px a la derecha. Fix: `Expanded` + `maxLines: 1` + ellipsis.
- El padding del ítem/logo, pensado para el ancho expandido (`240px`), desbordaba 6-11px al colapsar a `76px`. Fix: padding condicional más angosto (`AppSpacing.sm` en vez de `md`/`lg`/`xxl`) cuando `_collapsed == true`.
- La tarjeta de módulo del dashboard (`module_summary_card.dart`) desbordaba 2px verticalmente con `mainAxisExtent: 210` del `GridView` — medido con `getMaxIntrinsicHeight`, el contenido necesita hasta ~238px cerca de `Breakpoints.desktopMin` (1024px), donde la tarjeta se angosta a 2 columnas y el texto envuelve más líneas; se subió a `250` (ver [panel-principal.md](./panel-principal.md)).

Verificado sin overflow en 1024/1100/1280/1440/1920px de ancho, expandido, colapsado y con el submenú de Módulos abierto.

## Widgets

- `AppBackButton`/`HeaderClipper` (`shared/widgets/`): sin cambios.
- `ShellSidebar`/`ShellBottomNav`/`ShellHeader`/`ShellSection` (`presentation/widgets/`): exclusivos de `shell/` (`ShellHeader` es nuevo, ver arriba).

## Puntos de atención

- El bottom nav mobile es **solo íconos** (con `Tooltip` por accesibilidad) — se probó con labels visibles (siempre, y luego solo en el ítem activo) y ambas variantes truncaban texto en anchos móviles típicos (~390px / 5 secciones ≈ 78px por ítem); "Organización"/"Administración" no entran en ese espacio con ningún tamaño de fuente razonable.
- Diálogos abiertos con `showGeneralDialog`/`showDialog` desde una pantalla que vive en el navigator interno se montan, por defecto, en el navigator **raíz** (`useRootNavigator: true`) — mismo cuidado que antes, ver el caso de `JoinTenantScreen` en [organizaciones.md](./organizaciones.md).
- El filtrado de navegación por rol (mencionado en la propuesta original) **no se implementó en esta fase** — ver "Puntos abiertos" en [frontend-navigation-redesign.md](../frontend-navigation-redesign.md).
