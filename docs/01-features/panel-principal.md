# Feature: Panel Principal / Dashboard (`lib/features/dashboard`)

## Responsabilidad

Vista de inicio tras el login: resumen del estado de la cuenta, checklist de primeros pasos, accesos rápidos y actividad reciente. No tiene capa `domain`/`data` propia — es puramente `presentation`, consumidor de `AuthProvider` (feature `auth`) y de las rutas de `tenant`.

## Pantallas (`presentation/pages/`)

| Pantalla | Estado | Descripción |
|---|---|---|
| `PersonalDashboardPage` | **Activa**, ruta `/` del navigator interno de `MainLayout` | Panel real, conectado a `AuthProvider` |
| `AdminDashboardPage` | **Mockup, no enrutada** | Vista estática con datos financieros de ejemplo (saldo del fondo, indicadores, gráfica de barras con `fl_chart`) — sin controllers, sin llamadas a API, sin conexión a `AuthProvider`. Previsualización del futuro módulo de Gestión Financiera. |
| `MemberDashboardPage` | **Mockup, no enrutada** | Igual que la anterior mockup, con datos de ejemplo (ahorro personal, préstamo, liquidaciones, gráficas de línea/torta con `fl_chart`). Tampoco está referenciada desde ningún lugar de la app. |

## `PersonalDashboardPage` — composición (`presentation/widgets/personal/`)

`PremiumGradientHeader` + `HeaderUserBlock`, luego (según `hasOrganizations`):
- **Sin organizaciones**: `NoActiveOrganizationCard` con acciones para crear/unirse.
- **Con organizaciones**: `MainDashboardFeed` (recomendaciones inteligentes, actividad reciente, módulos próximos, organizaciones recientes) + `SideControlPanel` (checklist de primeros pasos, `MetricsSummaryBlock`, seguridad, actividad).

## Estado

`context.watch<AuthProvider>()` — es la única pantalla de la app que realmente depende de que `AuthProvider.notifyListeners()` se dispare para actualizarse en vivo (de ahí la importancia de `refreshSession()` al crear/unirse a una organización desde otras pantallas).

## Puntos de atención

- El grid de métricas mostraba antes una tarjeta "Permisos globales" calculada como `role == 'ADMIN' ? 15 : 5` — un número inventado a partir del nombre del rol. Se eliminó como parte del refactor de [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md), porque el frontend no debe inferir capacidades desde `roles`.
- `AdminDashboardPage`/`MemberDashboardPage` **no deben confundirse con funcionalidad activa** — no aparecen en `AppRoutes`, no se navegan desde ningún botón, y no hay forma de llegar a ellas desde la UI actual.
