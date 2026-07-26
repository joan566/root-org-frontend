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

**Known issue:** `test/widget_test.dart` is still the default Flutter counter-app template and does not match this app (`MainApp` renders `LoginPage`/`MainLayout`, not a counter). It currently fails (`flutter test` returns exit 1). Don't treat this as a regression you introduced; if you touch tests, this one needs rewriting to match real app behavior first.

## Architecture

The app follows **Clean Architecture**, organized as one module per business feature under `lib/features/`: `auth`, `user`, `tenant`, `dashboard`, `shell`, `core`. Every feature (except `shell`/`core`, which are cross-cutting) follows the same three-layer internal structure:

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
    controllers/   # plain (non-ChangeNotifier) classes that call a UseCase; also *Injection static factories
    pages/         # StatefulWidget/StatelessWidget screens, own their local loading/error state
    widgets/       # page-local UI pieces
    provider/      # ChangeNotifier state, currently only auth/presentation/provider/auth_provider.dart
```

Data flows one way: `Api` (JSON map) → `Model.fromJson` → `Mapper.toDomain` → `Entity` → `RepositoryAdapter` (implements `RepositoryPort`) → `UseCase.execute` → `Controller` → `Page`.

### Dependency wiring

There is no DI framework (no `get_it`, no `injectable`, no Riverpod). Each feature has an `*Injection` class (e.g. `AuthInjection`, `TenantInjection`, `UsersInjection`) with static factory methods that manually construct the chain from scratch: `Api()` → `RepositoryAdapter(api)` → `UseCase(repository)` → `Controller(useCase)`. Pages call these factories directly (e.g. `AuthInjection.login()`) rather than receiving controllers via a provider/injector — a new instance is built per call.

### State management

Two different mechanisms coexist, used for different things:
- **`AuthProvider`** (`ChangeNotifier`, wired via `provider` package at the app root in `main.dart`) holds the *only* global state: the current `LoginSesion` (token, `hasTenant`, `User`). Session is in-memory only — nothing is persisted to disk, so it resets on app restart. `MainApp` in `main.dart` decides `LoginPage` vs `MainLayout` based on `auth.isLogged`.
- **Everything else** (login/register forms, profile edits, tenant creation, etc.) uses plain non-reactive `Controller` classes instantiated per-page via the feature's `*Injection`. Pages manage their own loading/error/success UI state locally (typically `setState`), calling `await controller.someAction(...)` and catching exceptions thrown by the API layer.

### Navigation

Two-tier routing:
1. `MaterialApp` (in `main.dart`) only registers one named route (`AppRoutes.register`); its `home` is `LoginPage` or `MainLayout`.
2. `MainLayout` (`features/shell/presentation/pages/main_layout.dart`) owns its **own nested `Navigator`** (`_innerNavigatorKey`) with an `onGenerateRoute` switch over `AppRoutes` constants (tenants, profile, createTenant, joinTenant, changePassword, ...). A custom `NavigatorObserver` in the same file watches route changes on this inner navigator and syncs the bottom-nav `selectedIndex` accordingly.

`AppRoutes` (`features/core/routes/app_routes.dart`) centralizes route-name string constants. `AppNavigator` (`features/core/routes/app_navigator.dart`) wraps `Navigator.pushNamed`/`pushReplacementNamed`/etc. Some call sites use `AppNavigator`, others call `Navigator.pushNamed(context, ...)` directly — both target the nearest `Navigator` in context, so calls inside `MainLayout`'s subtree hit the inner navigator.

### Backend API

Each feature's datasource (`AuthApi`, `UserApi`, `TenantApi` in `data/datasources/`) is a thin `package:http` wrapper with private `_post`/`_get` helpers that JSON-encode/decode and throw `Exception(message)` on non-2xx responses or malformed bodies. There is **no shared HTTP client, no interceptor, and no central API config**: each of the three files independently hardcodes `baseUrl = "http://192.168.0.104:8080"` (a LAN IP — `TenantApi` additionally appends `/tenant`). If the backend host/port changes, update all three files. Auth is a bare `Bearer <token>` header passed explicitly into each authenticated call (token comes from `AuthProvider.session`) — there's no auto-refresh or persistent token storage.

### Naming conventions worth knowing

- Mapper classes are static-method-only (`ClassNameMapper.toDomain(model)`), never instantiated.
- `*Model` classes deserialize API responses 1:1; `*Entity`/domain classes are the app-internal shape used by everything above the `data/` layer — don't skip the mapper step or pass Models into `domain`/`presentation` code.
- Repository interfaces are suffixed `Port` (domain) and implementations `Adapter` (data) — a ports-and-adapters (hexagonal) naming convention layered on top of Clean Architecture.
