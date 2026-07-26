# Documento de Arquitectura de Navegación (ADR-012, Fase 1)

> Entregable de Fase 1 de [ADR-012](./ADR-012-refactor-arquitectura-frontend.md).

## 1. Estado actual (línea base)

Dos niveles de `Navigator`, documentados también en [arquitectura-frontend.md](../02-arquitectura/arquitectura-frontend.md):

1. **Navigator raíz** (`MaterialApp` en `main.dart`): una sola ruta nombrada, `AppRoutes.register` (`/register`). `home` alterna `LoginPage`/`MainLayout` según `AuthProvider.isLogged`.
2. **Navigator interno de `MainLayout`** (`features/shell/presentation/pages/main_layout.dart`): `Navigator` propio con `onGenerateRoute`, rutas resueltas por un `switch` manual:

   | Ruta (`AppRoutes`) | Page actual |
   |---|---|
   | `/` | `PersonalDashboardPage` |
   | `AppRoutes.tenants` (`/tenants`) | `TenantPage` |
   | `AppRoutes.profile` (`/profile`) | `ProfilePage` |
   | `AppRoutes.createTenant` (`/create-tenant`) | `CreateTenantPage` |
   | `AppRoutes.joinTenant` (`/join-to-tenant`) | `JoinTenantPage` |
   | `AppRoutes.changePassword` (`/change-password`) | `ChangePasswordPage` |
   | *(default)* | `PersonalDashboardPage` |

   Un `NavigatorObserver` (`_InnerRouteObserver`) sincroniza el índice del bottom nav con la ruta activa, mapeando por grupos (`/` → tab 0, tenants/create/join → tab 1, profile/changePassword → tab 3). El **tab 2 ("Usuarios") está reservado pero sin pantalla asignada** — hueco conocido, relevante para cuando se implemente el módulo de gestión de usuarios/organización.

   El FAB central siempre navega a `createTenant` sin importar el tab activo — acoplamiento implícito entre "acción flotante" y "crear organización" que no escala a otros módulos (ej. Financiero probablemente necesitará su propia acción flotante contextual).

3. `AppRoutes` centraliza los strings de ruta; `AppNavigator` envuelve `Navigator.pushNamed/pushReplacementNamed/pushNamedAndRemoveUntil/pop`. **No todo el código usa `AppNavigator`** — hay call sites que llaman `Navigator.pushNamed(context, ...)` directamente (ver inventario de duplicación/uso en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md)).

## 2. Problemas que esta refactorización debe resolver

- El `switch` de `onGenerateRoute` en `MainLayout` crecerá linealmente con cada módulo nuevo (Financiero, Inventario, Actividades, Préstamos...), concentrando el conocimiento de *todas* las rutas internas en un único archivo de la feature `shell`.
- No hay noción de rutas anidadas por feature — todo vive en un namespace plano (`AppRoutes`).
- El acoplamiento "tab index ↔ conjunto de rutas" está hardcodeado a mano (los tres `if` en `_InnerRouteObserver`), y no hay forma declarativa de decir "estas rutas pertenecen al tab de Organizaciones".
- La navegación no distingue Desktop de Mobile: en Desktop, previsiblemente varias de estas pantallas convivirán como paneles/side-by-side en vez de reemplazarse unas a otras en un único `Navigator` de pantalla completa.

## 3. Arquitectura objetivo

### 3.1 Principio: navegación sigue siendo centralizada, pero registrada por feature

`AppRoutes` dejará de ser una lista plana de constantes definida a mano; cada feature declarará sus propias rutas y las aportará a un registro central en `core/routing/`. Patrón concreto:

```
core/routing/
  app_routes.dart        # namespace consolidado, agrega los *Routes de cada feature
  app_navigator.dart      # sin cambios de contrato respecto a hoy
  route_registry.dart     # nuevo: mapea nombre de ruta -> builder de Screen, poblado por feature

features/<feature>/presentation/
  <feature>_routes.dart   # ej. TenantRoutes.tenants, TenantRoutes.createTenant
```

Esto es un cambio de organización, no de comportamiento: `Navigator.pushNamed(context, TenantRoutes.tenants)` sigue funcionando igual que hoy con `AppRoutes.tenants`. El objetivo es que **el shell no necesite conocer las pantallas de cada feature** para registrarlas — cada feature se auto-registra en el `route_registry.dart` central, de forma análoga a como cada feature ya tiene su propia `*Injection`.

### 3.2 Bottom nav ↔ grupos de rutas

Cada feature que participa del bottom nav declara explícitamente a qué tab pertenece (en vez de los `if` con literales de ruta hardcodeados en `MainLayout`). Esto es responsabilidad de `shell/`, que sigue siendo el dueño único de `MainLayout` y de la barra de navegación — solo cambia de dónde lee la tabla ruta→tab.

### 3.3 Navigator raíz vs. interno — sin cambios de fondo

El esquema de dos Navigators (raíz para `Login`/`Register` pre-sesión, interno en `MainLayout` para todo lo autenticado) se mantiene: sigue siendo la forma correcta de separar "flujo de autenticación" de "app autenticada con bottom nav persistente". El ADR-012 no propone tocar esto — el rediseño es sobre *cómo se registran* las rutas internas, no sobre *cuántos Navigators* existen.

### 3.4 Navegación y Responsive

En Desktop, una `Screen` puede decidir **no navegar** a pantalla completa para ciertas transiciones (ej. abrir el detalle de una organización como panel lateral en vez de una nueva ruta de `Navigator`). Esta decisión vive en la `*DesktopView` de cada pantalla, nunca en el registro de rutas — el registro de rutas siempre representa la navegación "canónica" (la que usa Mobile); Desktop puede optar por representar la misma transición de estado como composición visual en vez de push de ruta. Detalle en [04-estrategia-responsive.md](./04-estrategia-responsive.md).

## 4. Qué NO cambia

- `AppNavigator` mantiene exactamente su API pública actual (`push`, `replace`, `pushAndRemoveUntil`, `pop`, `canPop`).
- El mecanismo de `PopScope` interceptando el botón atrás del sistema para delegarlo al Navigator interno.
- El cuidado ya documentado sobre `showGeneralDialog`/`showDialog` usando `useRootNavigator: true` por defecto (capturar el `Navigator.of(context)` de la página antes de abrir un diálogo si se necesita hacer doble `pop`).
