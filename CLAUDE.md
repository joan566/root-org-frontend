# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter frontend for **SUMKEYA**, a multi-tenant savings-fund management platform (admins manage organizations/members, members operate financial modules). See `docs/00-core/01-vision/vision-frontend.md` (Spanish) for product vision.

## Commands

```bash
flutter pub get                    # install dependencies
flutter analyze                    # static analysis (flutter_lints via analysis_options.yaml)
flutter test                       # run all tests
flutter test test/widget_test.dart # run a single test file
flutter run                        # run the app (lib/main.dart is the entry point)
```

There is no CI config, no formatting/build script beyond the standard Flutter toolchain, and no `.env`/flavor setup — see "Backend URL" below.

`test/widget_test.dart` was rewritten (ADR-012 Fase 8, 2026-07-26) to a real smoke test: pumps `MainApp` wrapped in `ChangeNotifierProvider<AuthProvider>` and asserts `LoginScreen` renders. It suppresses `RenderFlex overflowed` errors specifically — `flutter test` measures text with a fallback test font whose glyphs are wider than the real fonts used at runtime, so a couple of tightly-fit rows (the disabled "Próximamente" social login buttons) report an overflow there that doesn't reproduce in an actual browser render at the same width (verified manually). `flutter test` passes.

## Architecture

**ADR-012 implemented (2026-07-26):** the frontend was restructured per [ADR-012](docs/00-core/07-refactor-arquitectura-frontend/ADR-012-refactor-arquitectura-frontend.md) — all 8 phases done: docs, `*Page`→`*Screen` rename, folder skeleton, splitting the 6 oversized screens, Desktop/Mobile views for the 3 screens with a genuinely distinct layout, `shared/` unification for the 2 components that were true duplicates, design-system tokens, and final validation (real browser screenshots at mobile/desktop widths, `flutter analyze` 0 errors, `flutter test` passing). A handful of risks were deliberately left open (inconsistent `AppNavigator` usage, hardcoded colors outside `AppColors`, an unimplemented bottom-nav tab) — see `ADR-012-plan-migracion.md` §5 for why each is out of scope.

The app follows **Clean Architecture**, organized as one module per business feature under `lib/features/`: `auth`, `user`, `tenant`, `dashboard`, `shell`. Cross-cutting infrastructure lives outside `features/`, in `lib/core/` and `lib/shared/`. Every business feature follows the same three-layer internal structure:

```
features/<feature>/
  data/
    datasources/   # *Api classes — raw HTTP calls via package:http, return Map<String, dynamic>
    models/        # *Model classes — mirror API JSON exactly, have fromJson factories
    mappers/       # static *Mapper.toDomain(model) — converts Model -> Entity
    repositories/  # *RepositoryAdapter implements the domain port, orchestrates Api -> Model -> Mapper -> Entity
  domain/
    entities/      # plain Dart classes, no framework/JSON dependency
    repositories/  # abstract *RepositoryPort interfaces (the contract data/ must fulfill)
    usecases/      # one class per action, holds a RepositoryPort, exposes execute(...)
  presentation/
    <screen>/      # one folder per Screen, e.g. login/, register/, profile/, create_tenant/
      <screen>_screen.dart   # StatefulWidget/StatelessWidget, owns its local loading/error state
      mobile/       # <Screen>MobileView (Fase 5, mostly not implemented yet)
      desktop/      # <Screen>DesktopView (Fase 5, mostly not implemented yet)
      widgets/      # UI pieces exclusive to this screen
      dialogs/      # dialogs exclusive to this screen
      bottom_sheets/ # bottom sheets exclusive to this screen
      forms/        # large forms extracted from this screen (mostly not done yet, Fase 4)
      state/        # controller(s)/injection exclusive to this screen
    state/          # controller/injection SHARED by 2+ screens of this feature (e.g. AuthInjection, TenantInjection, UsersInjection)
    widgets/        # widgets SHARED by 2+ screens of this feature (e.g. auth's BackendErrorCard)
    provider/       # ChangeNotifier state, currently only auth/presentation/provider/auth_provider.dart
```

`shell` and the future `core`-adjacent modules don't follow the per-screen split above: `shell/presentation/pages/main_layout.dart` is the persistent app shell (bottom nav + inner `Navigator`), not a routed Screen.

Data flows one way: `Api` (JSON map) → `Model.fromJson` → `Mapper.toDomain` → `Entity` → `RepositoryAdapter` (implements `RepositoryPort`) → `UseCase.execute` → `Controller` → `Screen`.

### `lib/core/` and `lib/shared/`

- `core/` holds cross-cutting infrastructure with no UI: `routing/` (`AppRoutes`, `AppNavigator`), `errors/` (`ApiException`), `design_system/colors/` (`AppColors`, includes shadow helpers `premiumShadow()`/`subtleShadow()`/`floatingShadow()` — elevation lives here, not in a separate `elevation/`/`shadows/` folder), `design_system/typography/` (`AppTypography`, Material-3-style scale), `design_system/spacing/` (`AppSpacing`), `design_system/radius/` (`AppRadius`), `design_system/breakpoints/` (`Breakpoints`). These are the *recommended defaults for new code* — existing widgets were not retroactively migrated to them (see ADR-012-plan-migracion.md, Fase 7). `design_system/{buttons,cards,dialogs,inputs,tables,navigation}/` and the other core subfolders (`networking`, `services`, `storage`, `constants`, `extensions`, `utils`) remain empty scaffolding — building those components without a concrete consumer would be premature abstraction, so they're deferred until a real need arises.
- `shared/` holds widgets/dialogs/layouts/navigation/forms/tables reused by **2+ features** (not just 2+ screens of the same feature — that case stays at the feature's own `presentation/widgets/`). Currently only `shared/widgets/app_back_button.dart` and `shared/widgets/header_clipper.dart` are populated (moved out of `shell/` because `tenant` and `user` already depended on them); the rest are empty, reserved for Fase 6 once the duplicated components identified in [ADR-012-plan-migracion.md](docs/00-core/07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md) get unified.

### Dependency wiring

There is no DI framework (no `get_it`, no `injectable`, no Riverpod). Each feature has an `*Injection` class (e.g. `AuthInjection`, `TenantInjection`, `UsersInjection`) with static factory methods that manually construct the chain from scratch: `Api()` → `RepositoryAdapter(api)` → `UseCase(repository)` → `Controller(useCase)`. Screens call these factories directly (e.g. `AuthInjection.login()`) rather than receiving controllers via a provider/injector — a new instance is built per call.

### State management

Two different mechanisms coexist, used for different things:
- **Root-registered `ChangeNotifier`s** (wired via `provider`'s `MultiProvider` in `main.dart`) hold state that must survive navigating away from the screen that loaded it and back — session/selection state (`AuthProvider` for the current `LoginSesion`: token, `hasTenant`, `User`; `TenantSessionController` for the active tenant; `ThemeController`) and **per-tenant backend caches** (`TenantUsersProvider` for `GET /tenant/{id}/users`, `OrganizationUnitsProvider` for organization units/departments). All of these are in-memory only — nothing is persisted to disk, so they reset on app restart. `MainApp` in `main.dart` decides `LoginScreen` vs the gate vs `MainShellScreen` based on `auth.isLogged`/`tenantSession.hasPassedGate`.
- **Everything else** (login/register forms, profile edits, tenant creation, etc.) uses plain non-reactive `Controller` classes instantiated per-screen via the feature's `*Injection`. Screens manage their own loading/error/success UI state locally (typically `setState`), calling `await controller.someAction(...)` and catching exceptions thrown by the API layer.

#### Rule: don't requery the backend for data that hasn't changed

A screen must not refetch data it (or another screen) already has in memory just because it was rebuilt by navigation — every avoidable `GET` is wasted backend load. This bit the app twice already: once with Estructura Organizacional's departments (fixed by `OrganizationUnitsProvider`), once with the tenant members list (fixed by `TenantUsersProvider`) — both ended up needing a promotion to a root-registered cache after starting as widget-local state. Skip that rework by applying this from the start whenever a screen loads a list/detail that:
- is shown in more than one place (a tab plus a detail screen, two tabs, etc.), or
- the user is expected to navigate away from and back to (switching bottom-nav tabs, pushing a detail screen, backgrounding the section).

How to apply it, following the `OrganizationUnitsProvider`/`TenantUsersProvider` pattern exactly:
1. Own the data in a `ChangeNotifier` registered in `main.dart`'s `MultiProvider`, keyed by tenant id (`Map<int, T>`), with `isLoaded(tenantId)`, a getter for the cached value, and a `load(tenantId, token)` that unconditionally (re)fetches and calls `notifyListeners()` — never catch errors inside it, let the caller's `try`/`catch` decide how to show them.
2. In the consuming screen's `initState`, check `isLoaded(tenantId)` first: if cached, read straight from the provider and skip the network call; only call `_load()` when it's genuinely missing.
3. Wire actual backend calls to exactly two triggers: the first-ever visit for that tenant, and an explicit manual refresh (`RefreshIndicator`/"Reintentar" button) — never to returning from a pushed screen or closing a bottom sheet.
4. After a create/update/delete mutation, apply the mutation response to the cached in-memory state directly (the provider's own `add`/`applyUpdate`-style methods) instead of reloading the list — the response (or a locally-inferable change) almost always already has what's needed.
5. If two features need the same backend list (e.g. both a members tab and a departments tab need tenant users), make one provider the single owner and have the other read/depend on it instead of keeping a second copy — don't cache the same endpoint's data in two places.
6. Register `.clear()` on every logout call site (there are currently two: `profile_screen.dart` and `my_organizations_screen.dart`) so cached data never leaks across accounts.

### Navigation

Two-tier routing:
1. `MaterialApp` (in `main.dart`) only registers one named route (`AppRoutes.register`); its `home` is `LoginScreen` or `MainLayout`.
2. `MainLayout` (`features/shell/presentation/pages/main_layout.dart`) owns its **own nested `Navigator`** (`_innerNavigatorKey`) with an `onGenerateRoute` switch over `AppRoutes` constants (tenants, profile, createTenant, joinTenant, changePassword, ...). A custom `NavigatorObserver` in the same file watches route changes on this inner navigator and syncs the bottom-nav `selectedIndex` accordingly.

`AppRoutes` (`core/routing/app_routes.dart`) centralizes route-name string constants. `AppNavigator` (`core/routing/app_navigator.dart`) wraps `Navigator.pushNamed`/`pushReplacementNamed`/etc. Some call sites use `AppNavigator`, others call `Navigator.pushNamed(context, ...)` directly — both target the nearest `Navigator` in context, so calls inside `MainLayout`'s subtree hit the inner navigator. See [ADR-012's navigation plan](docs/00-core/07-refactor-arquitectura-frontend/03-arquitectura-navegacion.md) for where this is headed (routes registered per-feature instead of one central switch).

### Backend API

Each feature's datasource (`AuthApi`, `UserApi`, `TenantApi` in `data/datasources/`) is a thin `package:http` wrapper with private `_post`/`_get` helpers that JSON-encode/decode responses. They throw plain `Exception(message)` for malformed/empty response bodies, and `ApiException` (`core/errors/api_exception.dart`, with `statusCode`/`errorCode`/`message`) for non-2xx responses — see [ADR-011](docs/00-core/06-api-integration/ADR-011-sistema-permisos.md). There is **no shared HTTP client, no interceptor, and no central API config**: each of the three files independently hardcodes `baseUrl = "http://192.168.0.104:8080"` (a LAN IP — `TenantApi` additionally appends `/tenant`). If the backend host/port changes, update all three files. Auth is a bare `Bearer <token>` header passed explicitly into each authenticated call (token comes from `AuthProvider.session`) — there's no auto-refresh or persistent token storage.

### Naming conventions worth knowing

- Mapper classes are static-method-only (`ClassNameMapper.toDomain(model)`), never instantiated.
- `*Model` classes deserialize API responses 1:1; `*Entity`/domain classes are the app-internal shape used by everything above the `data/` layer — don't skip the mapper step or pass Models into `domain`/`presentation` code.
- Repository interfaces are suffixed `Port` (domain) and implementations `Adapter` (data) — a ports-and-adapters (hexagonal) naming convention layered on top of Clean Architecture.
