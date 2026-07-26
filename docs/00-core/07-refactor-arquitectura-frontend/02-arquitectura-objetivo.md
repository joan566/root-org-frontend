# Documento de Arquitectura Frontend — Objetivo (ADR-012, Fase 1)

> Entregable de Fase 1 de [ADR-012](./ADR-012-refactor-arquitectura-frontend.md). No implica cambios de código; describe la estructura destino que guiará las Fases 2-8.

## 1. Estructura raíz

```
lib/
  core/
  shared/
  features/
  main.dart
```

Comparado con la estructura actual (`lib/features/{auth,user,tenant,dashboard,shell,core}`, ver [arquitectura-frontend.md](../02-arquitectura/arquitectura-frontend.md)), los cambios son:

- `core/` deja de ser "rutas + estilos" y pasa a ser infraestructura transversal completa.
- Aparece `shared/`, inexistente hoy — todo lo reutilizable entre 2+ features migra ahí.
- `shell/` **no desaparece como feature**: sigue existiendo como el feature dueño de `MainLayout` y del Navigator interno (es específico de la app, no reutilizable entre features), pero su navegación de bajo nivel se apoya en primitivas de `core/routing/` y `shared/navigation/`.
- `features/` gana los módulos de negocio futuros (`organization`, `financial`, `inventory`, `activities`, `loans`, ...) sin cambiar el patrón.

## 2. `core/` — infraestructura transversal

```
core/
  routing/        # AppRoutes, AppNavigator (hoy en features/core/routes/)
  networking/      # cliente HTTP compartido (hoy no existe: 3 *Api duplican _post/_get)
  services/        # servicios transversales sin dueño único de feature
  storage/          # hoy no existe: sesión es solo in-memory (ver AuthProvider)
  design_system/   # ver sección 4
  constants/
  extensions/
  utils/
  errors/          # ApiException (hoy en features/core/errors/)
```

`core/` nunca depende de `features/`. Puede ser importado por cualquier feature o por `shared/`.

## 3. `shared/` — reutilizable entre features

```
shared/
  widgets/     # ej. RoleChip si se usa en más de un feature, empty states genéricos
  dialogs/     # diálogos de confirmación genéricos, no ligados a una feature
  layouts/     # scaffolds/base layouts reutilizados (ej. layout con header + bottom nav)
  navigation/  # helpers de navegación no específicos de una feature (ej. resolución responsive de rutas)
  forms/       # inputs/validators genéricos reutilizados entre formularios de distintas features
  tables/      # tablas genéricas (ej. PermissionTable, listados tabulares en Desktop)
```

**Criterio de promoción a `shared/`:** un componente se mueve a `shared/` solo cuando tiene **2 o más consumidores en features distintas** con la misma semántica visual. Un widget usado una sola vez, o duplicado por casualidad pero con semántica distinta (ej. dos "cards" que muestran cosas diferentes y solo coinciden en el borde redondeado), se queda en `presentation/<screen>/widgets/` de su feature y punto — no se promueve preventivamente. Sobre-promover a `shared/` sin un segundo consumidor real genera acoplamiento innecesario entre features.

## 4. `core/design_system/`

```
design_system/
  colors/        # reemplaza/absorbe features/core/presentation/styles/app_colors.dart
  typography/
  spacing/
  radius/
  elevation/
  shadows/
  breakpoints/   # también consumido por shared/layouts para decidir Desktop/Mobile (ver 04-estrategia-responsive.md)
  buttons/
  cards/
  dialogs/
  inputs/
  tables/
  navigation/
```

Regla: cualquier componente visual nuevo (botón, card, input, tabla) se construye **componiendo** primitivas de `design_system/`, nunca definiendo colores/espaciados/radios ad-hoc dentro de una feature. Los widgets de negocio (`UserCard`, `FinancialSummaryCard`) usan `design_system/` como base, pero viven en `shared/widgets/` o en la feature, no dentro del design system.

## 5. Estructura de una Feature

```
features/<feature>/
  data/
    datasources/
    models/
    mappers/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    <screen>/
      <screen>_screen.dart
      mobile/
        <screen>_mobile_view.dart
      desktop/
        <screen>_desktop_view.dart
      widgets/          # widgets usados SOLO por esta screen
      dialogs/
      bottom_sheets/
      forms/
      state/            # controller(s) + injection de esta screen
```

`data/` y `domain/` **no cambian de forma** respecto a la arquitectura actual — el ADR-012 no toca esas capas, solo reorganiza `presentation/`.

### Ejemplo concreto: `auth/login`

Mapeo del estado actual al objetivo:

| Hoy | Objetivo |
|---|---|
| `auth/presentation/pages/login_page.dart` (345 líneas, `LoginPage`) | `auth/presentation/login/login_screen.dart` (`LoginScreen`, decide Desktop/Mobile) |
| — (todo en un archivo) | `auth/presentation/login/mobile/login_mobile_view.dart` (`LoginMobileView`) |
| — (todo en un archivo) | `auth/presentation/login/desktop/login_desktop_view.dart` (`LoginDesktopView`) |
| `auth/presentation/widgets/login/*.dart` (6 archivos: `backend_error_card`, `create_account_card`, `left_identity_panel`, `login_form_header`, `login_utils`, `social_logins_grid`) | `auth/presentation/login/widgets/*.dart` (mismos archivos, movidos bajo la screen) |
| `auth/presentation/controllers/login_controller.dart` + porción de `auth_injection.dart` | `auth/presentation/login/state/login_controller.dart` + `login_injection.dart` (o `auth_injection.dart` compartido si sigue sirviendo a varias screens del feature) |

Este mismo patrón de mapeo se repite para cada pantalla — el detalle completo (las 8 screens grandes con su desglose de responsabilidades) está en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md).

## 6. Convenciones de nombres (resumen, detalle en el ADR)

| Elemento | Sufijo/patrón |
|---|---|
| Screen (ruta principal) | `*Screen` (nunca `*Page`) |
| Vista por plataforma | `*DesktopView` / `*MobileView` |
| Widget reutilizable | Sustantivo, sin lógica de navegación (`UserCard`, no `UserCardWithNavigation`) |
| Diálogo | vive en `dialogs/`, nombre descriptivo + `Dialog` |
| Bottom sheet | vive en `bottom_sheets/`, nombre descriptivo + `BottomSheet` |
| Formulario grande | vive en `forms/`, nombre descriptivo + `Form` |
| Controller / provider / injection | viven en `state/` |

## 7. Qué NO cambia

- Las 3 capas de Clean Architecture (`data`/`domain`/`presentation`) y su dirección de dependencia.
- Los nombres y contratos de `*Model`, `*Mapper`, `*Entity`, `*RepositoryPort`/`*Adapter`, `*UseCase`.
- El mecanismo de wiring manual vía `*Injection` (se reubica dentro de `state/` de cada screen, pero el patrón — sin contenedor de DI — se mantiene).
- `AuthProvider` como único estado global reactivo.
