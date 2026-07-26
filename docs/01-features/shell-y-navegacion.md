# Feature: Shell y Navegación (`lib/features/shell`)

## Responsabilidad

El layout de la app una vez autenticado: bottom navigation, botón flotante de acceso rápido, y el navigator interno que resuelve todas las pantallas autenticadas. No contiene lógica de negocio — es infraestructura de navegación y composición visual.

## `MainLayout` (`presentation/pages/main_layout.dart`)

- `Scaffold` con `bottomNavigationBar` (4 posiciones: Inicio, Organizaciones, Usuarios [reservado, sin pantalla], Perfil) y un `FloatingActionButton` que abre directamente `CreateTenantScreen`.
- Contiene un `Navigator` propio (`_innerNavigatorKey`), con `initialRoute: '/'` y su propio `onGenerateRoute`, que resuelve: `/` → `PersonalDashboardScreen`, `AppRoutes.tenants` → `TenantScreen`, `AppRoutes.profile` → `ProfileScreen`, `AppRoutes.createTenant` → `CreateTenantScreen`, `AppRoutes.joinTenant` → `JoinTenantScreen`, `AppRoutes.changePassword` → `ChangePasswordScreen`; cualquier otro nombre (incluido `/dashboard`) cae en `default` → `PersonalDashboardScreen`.
- Un `NavigatorObserver` interno (`_InnerRouteObserver`) escucha los cambios de ruta de ese navigator y sincroniza el índice resaltado del bottom nav.
- `PopScope(canPop: false, ...)` intercepta el botón de retroceso del sistema para delegarlo al navigator interno (`navigator.pop()`) en vez de dejar que cierre `MainLayout` completo — importante: esta protección cubre el back del sistema/`maybePop`, **no** un `Navigator.of(context).pop()` imperativo llamado directamente sobre el navigator raíz desde código de la app.

## Widgets

> **Actualización 2026-07-26:** `AppBackButton` y `HeaderClipper` se movieron de `shell/presentation/widgets/` a `shared/widgets/` — ya eran consumidos por las features `tenant` y `user` además de `shell`, cumpliendo el criterio de promoción a `shared/` de [ADR-012](../00-core/07-refactor-arquitectura-frontend/02-arquitectura-objetivo.md).

- `AppBackButton` (`shared/widgets/app_back_button.dart`): botón de retroceso reutilizable, usa `AppNavigator.pop(context)` por defecto (configurable con `onPressed`).
- `HeaderClipper` (`shared/widgets/header_clipper.dart`): clipper custom para las cabeceras con forma curva usadas en varias pantallas.

## Puntos de atención

- Diálogos abiertos con `showGeneralDialog`/`showDialog` desde una pantalla que vive en el navigator interno se montan, por defecto, en el navigator **raíz** (`useRootNavigator: true`). Si el flujo necesita cerrar el diálogo y además volver una pantalla atrás, hay que capturar `Navigator.of(context)` de la página *antes* de abrir el diálogo (ver el caso de `JoinTenantScreen` en [organizaciones.md](./organizaciones.md)) — reusar el mismo `context` para ambos `pop()` puede terminar sacando la única ruta del navigator raíz (`MainLayout`), dejando la pantalla en negro.
- No hay pantalla asignada todavía al espacio "Usuarios" del bottom nav (`index == 2` en `_onItemTapped` no hace nada).
