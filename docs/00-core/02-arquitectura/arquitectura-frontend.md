# Arquitectura del Frontend

> **En refactor (ADR-012).** Este documento describe el estado **actual** del código (Fases 1-3 de [ADR-012](../07-refactor-arquitectura-frontend/ADR-012-refactor-arquitectura-frontend.md) ya aplicadas: pantallas renombradas a `*Screen`, `core/`/`shared/` creados). Las Fases 4-8 (dividir pantallas grandes, vistas Desktop/Mobile, unificar `shared/`, design system) siguen pendientes — ver el [plan de migración](../07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md) para el detalle de lo que falta.

## Visión general

El frontend de SUMKEYA es una aplicación Flutter (multiplataforma: Android, iOS, Web, Linux, Windows, macOS) organizada en **módulos por feature de negocio**, cada uno siguiendo **Clean Architecture** en tres capas. No se usa ningún framework de inyección de dependencias (`get_it`, `injectable`, Riverpod) ni gestión de estado global unificada: cada módulo resuelve su propio wiring y su propio estado con las herramientas mínimas necesarias.

```
lib/
  core/          # infraestructura transversal, sin UI de negocio
    routing/       # AppRoutes, AppNavigator
    errors/        # ApiException
    design_system/ # colors/ (poblado); typography, spacing, radius, elevation,
                   # shadows, breakpoints, buttons, cards, dialogs, inputs,
                   # tables, navigation (esqueleto vacio, Fases 6-7)
    networking/ services/ storage/ constants/ extensions/ utils/  # esqueleto vacio
  shared/        # reutilizable entre 2+ FEATURES (no solo 2+ pantallas de una feature)
    widgets/       # AppBackButton, HeaderClipper (poblado); resto vacio, Fase 6
    dialogs/ layouts/ navigation/ forms/ tables/  # esqueleto vacio
  features/
    auth/        # login, registro, recuperación de contraseña, sesión global
    user/         # perfil, cambio de contraseña
    tenant/       # organizaciones: crear, unirse, listar
    dashboard/    # panel principal (personal); mocks de admin/miembro (eliminados, no vigentes)
    shell/        # layout autenticado, navegación interna, bottom nav
  main.dart       # composition root
```

## Las tres capas de cada feature

```
features/<feature>/
  data/
    datasources/   # *Api — HTTP puro (package:http), request/response como Map<String, dynamic>
    models/        # *Model — espejo exacto del JSON, con fromJson
    mappers/       # *Mapper — Model -> Entity (métodos estáticos, sin estado)
    repositories/  # *RepositoryAdapter — implementa el puerto, orquesta Api -> Model -> Mapper -> Entity
  domain/
    entities/      # clases planas, sin dependencia de framework ni de JSON
    repositories/  # *RepositoryPort — interfaz abstracta (el contrato que data/ debe cumplir)
    usecases/      # una clase por acción de negocio, ejecuta sobre un RepositoryPort
  presentation/
    <screen>/      # una carpeta por Screen (ej. login/, register/, profile/, create_tenant/)
      <screen>_screen.dart  # pantalla (Stateful/Stateless), dueña de su propio loading/error local
      mobile/        # <Screen>MobileView (Fase 5 — mayormente sin implementar aun)
      desktop/       # <Screen>DesktopView (Fase 5 — mayormente sin implementar aun)
      widgets/       # piezas de UI exclusivas de esta pantalla
      dialogs/       # dialogos exclusivos de esta pantalla
      bottom_sheets/ # bottom sheets exclusivos de esta pantalla
      forms/         # formularios grandes extraidos (Fase 4 — mayormente sin hacer aun)
      state/         # controller(s)/injection exclusivos de esta pantalla
    state/         # controller/injection COMPARTIDO por 2+ pantallas de la feature (ej. AuthInjection)
    widgets/       # widgets COMPARTIDOS por 2+ pantallas de la feature (ej. BackendErrorCard en auth)
    provider/      # estado reactivo (ChangeNotifier) — hoy solo existe en auth/
```

`shell` es la excepción: `main_layout.dart` es el shell persistente de la app (bottom nav + Navigator interno), no una Screen enrutada, así que no sigue el desglose por pantalla de arriba.

El flujo de datos siempre va en una sola dirección:

```
Api (JSON) → Model.fromJson → Mapper.toDomain → Entity → RepositoryAdapter (implementa RepositoryPort)
           → UseCase.execute → Controller → Screen
```

Los `Model` nunca cruzan hacia `domain/` ni `presentation/`; solo los `Entity` lo hacen. Saltarse el mapper (pasar un `Model` directo a una pantalla) rompe la separación de capas.

## Wiring de dependencias — clases `*Injection`

No hay contenedor de DI. Cada feature expone una clase estática `*Injection` (`AuthInjection`, `TenantInjection`, `UsersInjection`) con factory methods que construyen la cadena completa a mano, desde cero, en cada llamada:

```dart
static LoginController login() {
  final authApi = AuthApi();
  final repository = AuthRepositoryAdapter(authApi);
  final useCase = LoginUserUseCase(repository);
  return LoginController(useCase);
}
```

Las pantallas llaman a estos factories directamente en `initState()` (ej. `AuthInjection.login()`), obteniendo una instancia nueva de todo el árbol de dependencias cada vez que se navega a esa pantalla. `AuthInjection`/`TenantInjection`/`UsersInjection` siguen usados por varias pantallas de su feature (ver [ADR-012-plan-migracion.md](../07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)), por eso viven en `presentation/state/` a nivel de feature y no dentro de una sola carpeta `<screen>/`.

## Gestión de estado

Conviven dos mecanismos, para propósitos distintos:

- **`AuthProvider`** (`ChangeNotifier`, vía `package:provider`, montado en la raíz en `main.dart`): es el **único estado global** de la app. Guarda la `LoginSesion` actual (token, `hasTenant`, `User`). Es **en memoria únicamente** — no hay persistencia en disco, la sesión se pierde al reiniciar la app. `MainApp` decide `LoginScreen` vs `MainLayout` según `auth.isLogged`. `AuthProvider` expone `login()`, `logout()`, `updateUser()` y `refreshSession()` (este último solo dispara `notifyListeners()`, para cuando otro código muta la sesión por referencia y necesita forzar la re-suscripción de los widgets que hacen `context.watch<AuthProvider>()`).
- **Todo lo demás** (formularios de login/registro, edición de perfil, creación de organización, etc.) usa `Controller` planos, sin `ChangeNotifier`, instanciados por pantalla vía `*Injection`. Cada pantalla maneja su propio `_isLoading`/error local con `setState`.

**Cuidado con las mutaciones directas de la sesión.** Código como `session.hasTenant = true; user.tenants.add(...)` (en los flujos de crear/unirse a organización) muta el objeto de sesión por referencia sin pasar por `AuthProvider`. Si algún widget más adelante depende de `context.watch<AuthProvider>()` para reflejar ese cambio, hay que llamar explícitamente `context.read<AuthProvider>().refreshSession()` después de mutar — si no, el widget no se entera hasta que algo más dispare `notifyListeners()`.

## Navegación — dos niveles de Navigator

1. **Navigator raíz** (`MaterialApp` en `main.dart`): registra una única ruta con nombre (`AppRoutes.register` → `/register`). Su `home` alterna entre `LoginScreen` y `MainLayout` según `auth.isLogged`. `RegisterScreen` se llega con `Navigator.pushNamed(context, "/register")` desde `LoginScreen` — queda apilada encima de login, así que para volver se usa `Navigator.pop(context)`, nunca un salto a una ruta con nombre que no existe (`/login` no está registrada).
2. **Navigator interno de `MainLayout`** (`features/shell/presentation/pages/main_layout.dart`): un `Navigator` propio (`_innerNavigatorKey`) con su propio `onGenerateRoute`, que resuelve `AppRoutes.tenants`, `.profile`, `.createTenant`, `.joinTenant`, `.changePassword` y `/` (dashboard). Un `NavigatorObserver` interno sincroniza el índice del bottom nav con la ruta activa. Un `PopScope(canPop: false, ...)` en `MainLayout` intercepta el botón de retroceso del sistema para delegarlo al navigator interno en vez de cerrar `MainLayout`.

Al abrir un diálogo (`showDialog`/`showGeneralDialog`) desde una pantalla que vive dentro del navigator interno, hay que tener cuidado: `showGeneralDialog` usa `useRootNavigator: true` por defecto, así que el diálogo se monta en el navigator **raíz**, no en el interno. Si el diálogo necesita cerrar tanto el diálogo como la pantalla que lo abrió, hay que capturar el `Navigator.of(context)` de la página **antes** de abrir el diálogo y usarlo para el segundo `pop`, no reutilizar el `context` del propio diálogo.

`AppRoutes` (`core/routing/app_routes.dart`) centraliza los nombres de ruta. `AppNavigator` (`core/routing/app_navigator.dart`) envuelve `Navigator.pushNamed`/`pushReplacementNamed`/etc. No todo el código usa `AppNavigator` de forma consistente — algunos call sites llaman `Navigator.pushNamed(context, ...)` directamente (ver el riesgo documentado en [ADR-012-plan-migracion.md](../07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)).

## Capa de API

Cada feature con acceso a red tiene su propio `*Api` (`AuthApi`, `UserApi`, `TenantApi`) en `data/datasources/`, un wrapper delgado sobre `package:http` con métodos privados `_post`/`_get` que:

1. Hacen la petición HTTP con `Content-Type: application/json` y, si aplica, `Authorization: Bearer <token>`.
2. Decodifican el body como `Map<String, dynamic>`.
3. Si el status es 200/201, devuelven el mapa decodificado.
4. Si no, lanzan `ApiException` (`core/errors/api_exception.dart`) con `statusCode`, `errorCode` (el campo `error` del shape de error del backend) y `message`.

No hay cliente HTTP compartido — los tres archivos duplican la misma lógica `_post`/`_get` de forma independiente. `ApiException.toString()` devuelve solo el `message`, por lo que el código de UI existente (`catch (e) { setState(() => _error = e.toString()...) }`) sigue funcionando sin cambios; el `statusCode`/`errorCode` quedan disponibles para quien necesite discriminar (ej. `403 FORBIDDEN_ERROR`, ver [ADR-011](../06-api-integration/ADR-011-sistema-permisos.md)).

Cada `*Api` hardcodea su propio `baseUrl` (`http://192.168.0.104:8080`, una IP de LAN) — no hay configuración por entorno (`.env`, flavors). Cambiar de backend implica editar los tres archivos.

## Autorización — principio de ADR-011

El campo `roles` que trae cada relación usuario↔tenant es **puramente informativo** (para mostrar un badge, ej. "Admin"). El frontend no debe usarlo para decidir mostrar/ocultar funcionalidad — esa validación vive en el backend. Ver [ADR-011-sistema-permisos.md](../06-api-integration/ADR-011-sistema-permisos.md) para el detalle completo.

## Referencias

- [Modelo de dominio](../05-dominio/modelo-dominio.md)
- [Contrato de API](../06-api-integration/contrato-api.md)
- Fichas técnicas por feature: [docs/01-features/](../../01-features/)
