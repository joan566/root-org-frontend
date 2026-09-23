# Feature: Panel Principal / Dashboard (`lib/features/dashboard`)

> **Actualización 2026-07-26 (Fase 2 del rediseño de navegación):** `PersonalDashboardScreen` se renombró/evolucionó a `DashboardGeneralScreen` (carpeta `presentation/personal_dashboard/` → `presentation/dashboard_general/`). Ver [docs/frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §2 y [shell-y-navegacion.md](./shell-y-navegacion.md).
>
> **Actualización 2026-07-26 (rediseño visual SaaS premium, Desktop):** `DashboardGeneralScreen` ahora bifurca por `Breakpoints.isDesktopContext(context)`. Desktop tiene una composición nueva (`desktop/dashboard_general_desktop_view.dart`), estilo Notion/Linear/Stripe (tarjetas planas, azul `#2563EB` como color primario — ver [ADR-013](../00-core/08-theming/ADR-013-modo-oscuro.md), la paleta cambió globalmente). Mobile/tablet (`< 1024px`) sigue exactamente igual que antes de este cambio — ver §"Vista desktop" más abajo.
>
> **Actualización 2026-07-26 (2ª iteración visual, "Centro de Operaciones"):** sobre el rediseño anterior, se ajustó jerarquía y densidad para acercarse más a Stripe/Linear/Vercel: `AppRadius.card` pasó de `18` a `20`; cada tarjeta de módulo tiene un color de identidad propio (reutiliza tokens existentes: Financiera=`primary`, Inventario=`warning`, Actividades=`secondary`, Préstamos=`success` — no se agregaron colores nuevos); `OrganizationStatusBanner` ganó un avatar con la inicial de la organización y un tercer stat real (`Tenant.code`); `QuickActionsRow` pasó de chips circulares a tarjetas-botón con descripción y elevación al hover. Se mantiene el mismo criterio de honestidad: ningún número/gráfico se inventó donde no hay backend (ver detalle por widget más abajo).
>
> **Actualización 2026-07-27 (rediseño visual mobile, mismo lenguaje "Centro de Operaciones"):** la composición mobile/tablet anterior (`PremiumGradientHeader`, `HeaderUserBlock`, `MainDashboardFeed`, `SideControlPanel` y sus widgets) se reemplazó por completo por `mobile/dashboard_general_mobile_view.dart`, con el mismo lenguaje visual plano ya aprobado en desktop. Ver §"Vista mobile" más abajo. De paso, `ModuleSummaryCard`, `DashboardActivityCard`/`DashboardPendingCard` y los catálogos de módulos/acciones rápidas se movieron a `widgets/` (nivel de pantalla) porque ahora los usan **ambas** vistas — antes vivían bajo `desktop/widgets/`.

## Responsabilidad

Centro de control de la organización activa tras el login: organización activa (con acción para cambiarla), resumen del estado de la cuenta, accesos rápidos, módulos disponibles y actividad reciente. No tiene capa `domain`/`data` propia — es puramente `presentation`, consumidor de `AuthProvider` (feature `auth`), `TenantSessionController` (`core/session/`) y de las rutas de `tenant`.

## Pantallas (`presentation/<screen>/`)

| Pantalla | Estado | Descripción |
|---|---|---|
| `DashboardGeneralScreen` | **Activa**, `AppRoutes.dashboard` (`initialRoute` del navigator interno de `MainShellScreen`) | Panel real, conectado a `AuthProvider` y `TenantSessionController` |

> `AdminDashboardPage`/`MemberDashboardPage` (mockups estáticos, no enrutados) se eliminaron en ADR-012 (ver [ADR-012-plan-migracion.md](../00-core/07-refactor-arquitectura-frontend/ADR-012-plan-migracion.md)) — el dashboard de miembro/admin diferenciado por rol sigue sin construirse; hoy hay un único `DashboardGeneralScreen` para todos los roles.

## Vista mobile (`presentation/dashboard_general/mobile/`, `< 1024px`)

`DashboardGeneralScreen` compone, para mobile/tablet: `mobile/widgets/dashboard_header_mobile.dart` (header fijo ~72px, fuera del scroll) + `Expanded(SingleChildScrollView(child: DashboardGeneralMobileView(...)))` + `mobile/widgets/quick_actions_fab.dart` (superpuesto con un `Stack`, no dentro del `Scaffold.floatingActionButton` — así el scrim del menú cubre exactamente el área de esta pantalla, por encima del bottom nav que vive en el `Scaffold` del shell). Mismo criterio de honestidad, mismos colores/tokens que la vista desktop; ver "Vista desktop" más abajo para el detalle de cada tarjeta compartida.

- **`DashboardHeaderMobile`** — logo + nombre de la organización activa (tocable si 2+ organizaciones, mismo destino `MyOrganizationsScreen(isInitialSelection: false)` que el chip de siempre), notificaciones decorativas (sin backend, sin contador inventado — mismo criterio que el buscador de `ShellHeader`), y avatar con la inicial del usuario **funcional**: navega a `AppRoutes.profile` (antes, en `HeroStateCard`, los botones equivalentes eran `onPressed: () {}` — no hacían nada).
- **`DashboardGeneralMobileView`** — si `!hasOrganizations`, `NoActiveOrganizationView` (compartida con desktop). Si hay organizaciones: `OrganizationStatusCardMobile` (versión vertical de `OrganizationStatusBanner`, mismos 3 stats reales, sin donut de "% adopción" — no existe ese dato) → título + saludo → los 4 `ModuleSummaryCard` **apilados en un `Column`** (no en grid como desktop) — al dimensionarse por contenido natural, evita la clase de bug de overflow por altura fija que sí hizo falta resolver en el grid 2×2 de desktop → `DashboardActivityCard` → `DashboardPendingCard` (mismos widgets compartidos, mismo estado vacío honesto).
- **`QuickActionsFab`** — en mobile, "Acciones rápidas" no vive en el cuerpo del scroll (a diferencia de desktop): un FAB circular de 64px despliega, con fade+scale, las mismas 6 acciones reales de `quickActionsCatalog` (compartido con `QuickActionsRow` de desktop). Reemplaza a `QuickActionsGrid` — mismas acciones, sin la parte "acciones directas de control" del cuerpo.

**Se eliminó también, sin reemplazo, por decluttering** (decisión explícita, no se recuperó en ningún lado): "Recomendaciones para ti" (`SmartRecommendationsSection`) y "Organizaciones recientes" (`RecentOrganizationsList` — el cambio de organización ahora se hace desde el header, igual que en desktop), "Primeros pasos" (`FirstStepsChecklist`) y `SecurityManagementCard` (mismo criterio que desktop, que tampoco los tiene — "Seguridad" ya existe como acción rápida real). `RecentActivityTimeline` (actividad **inventada** hardcodeada: "Juan registró un movimiento", "Hace 5 min", etc.) se reemplazó por el `DashboardActivityCard` honesto compartido con desktop.

## Vista desktop (`presentation/dashboard_general/desktop/`)

`DashboardGeneralDesktopView` reemplaza toda la composición anterior cuando `Breakpoints.isDesktopContext(context)` es verdadero (`≥1024px`). No incluye `PremiumGradientHeader`/`HeaderUserBlock` propios — el header y el selector de organización ya los cubre `ShellHeader` a nivel del shell (ver [shell-y-navegacion.md](./shell-y-navegacion.md)). Composición, de arriba a abajo:

1. **`widgets/organization_status_banner.dart`** — tarjeta plana con avatar (inicial de la organización), nombre/descripción de la organización activa (`Tenant`), badge de estado (`UserTenant.status`) y 3 stats reales en un `Wrap`: total de organizaciones del usuario, rol activo y `Tenant.code` (código de invitación). No muestra "Departamentos", "% de adopción de módulos" ni "última actividad": no existe backend para eso hoy, y se omiten en vez de inventarse (mismo criterio que "Puntos de atención" más abajo) — por eso tampoco hay gráfico circular de adopción, solo el avatar de la organización.
2. Título "Dashboard General" + saludo con el nombre real del usuario.
3. **`widgets/module_summary_card.dart`** (grid 2×2, `mainAxisExtent: 250`) — Gestión Financiera / Inventario / Actividades / Gestión de Préstamos, mismo estado honesto "Próximamente" que ya usaba `UpcomingModulesSection` (ningún módulo tiene backend propio todavía), tarjeta grande con línea superior + icono en el color de identidad del módulo (Financiera=`AppColors.primary`, Inventario=`warning`, Actividades=`secondary`, Préstamos=`success` — reutiliza tokens ya existentes, no colores nuevos). Las 4 navegan a `AppRoutes.modules`. El alto fijo del grid se midió con `getMaxIntrinsicHeight` (~212px en tarjetas anchas, ~238px cerca de `Breakpoints.desktopMin` donde el texto envuelve más líneas al angostarse a 2 columnas); 250 cubre el peor caso.
4. **`widgets/dashboard_activity_card.dart`** / **`widgets/dashboard_pending_card.dart`** — "Actividad reciente" y "Pendientes importantes". No existe backend de auditoría ni de solicitudes por organización, así que ambas muestran un estado vacío honesto (título + descripción corta, ej. "Aún no hay actividad registrada" / "Los eventos de tu organización aparecerán aquí.") en vez de un feed, timeline o contadores inventados.
5. **`widgets/quick_actions_row.dart`** — las 6 acciones reales de `widgets/quick_actions_catalog.dart` (Mis organizaciones, Editar perfil, Seguridad, Crear organización, Unirse por código, Configuración — compartido con `QuickActionsFab` de mobile), como tarjetas-botón (icono + título + descripción) en un `Wrap`, con elevación sutil al pasar el mouse.

Todos usan `AppColors.of(context).flatCardDecoration()` (tarjeta blanca plana con borde + sombra sutil, radio `AppRadius.card` = 20) y los tokens `AppSpacing`/`AppTypography` del design system — mismo criterio en la vista mobile (§"Vista mobile" arriba).

### Organización activa

`DashboardGeneralScreen` resuelve la organización activa con `context.watch<TenantSessionController>().resolveActive(tenantsList)` — ya no toma `tenantsList.first` a ciegas (bug real señalado en [frontend-navigation-redesign.md](../frontend-navigation-redesign.md) §1, corregido en Fase 2). El nombre de la organización activa es tocable para cambiarla (si el usuario pertenece a 2+): `ShellHeader` en desktop (ver [shell-y-navegacion.md](./shell-y-navegacion.md)), `DashboardHeaderMobile` en mobile — ambos abren `MyOrganizationsScreen(isInitialSelection: false)` (`features/tenant/presentation/my_organizations/`) como una pantalla empujada sobre el navigator interno del shell, con botón de retroceso; al elegir una organización distinta, hace `pop()` en vez de reemplazar la pila — el dashboard ya escucha `TenantSessionController` y se actualiza solo.

### Módulos

`moduleCatalog` (`widgets/module_catalog.dart`) centraliza los módulos reales del mapa de navegación (Gestión Financiera, Inventario, Actividades, Gestión de Préstamos) + su color de identidad — compartido por `ModuleSummaryCard` en ambas vistas. Ninguno tiene backend hoy, así que las 4 tarjetas son honestas ("Próximamente") y navegan a `AppRoutes.modules` (el mismo placeholder genérico del shell). No inventan badges de disponibilidad como la versión anterior.

## El drawer se eliminó (Fase 2)

`PersonalDashboardScreen` tenía un `Drawer` (Dashboard/Organizaciones/Mi Perfil/Cerrar sesión) que resultó ser **código muerto**: el `Scaffold` no tenía `AppBar`, por lo que Flutter nunca renderizaba el botón hamburguesa automático, y nada más llamaba `_scaffoldKey.currentState?.openDrawer()`. Era inalcanzable desde la UI. Se eliminó junto con `_buildProfessionalDrawer`/`_drawerItem` — la navegación equivalente ya la cubre el shell (sidebar/bottom nav) y `LogoutCard` en `ProfileScreen`.

## Estado

`context.watch<AuthProvider>()` y `context.watch<TenantSessionController>()` — el dashboard se actualiza en vivo con `AuthProvider.notifyListeners()` (de ahí la importancia de `refreshSession()` al crear/unirse a una organización) y con cualquier cambio de organización activa.

## Puntos de atención

- El grid de métricas mostraba antes una tarjeta "Permisos globales" calculada como `role == 'ADMIN' ? 15 : 5` — un número inventado a partir del nombre del rol. Se eliminó como parte del refactor de [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md), porque el frontend no debe inferir capacidades desde `roles`. El mismo criterio se aplicó en Fase 2 a `activeModules`: antes hardcodeado a `4` (otro número inventado), luego `0` (honesto). Ese widget (`MetricsSummaryBlock`) se eliminó por completo en el rediseño mobile de 2026-07-27 — la info real que quedó (organizaciones/rol/código) vive en `OrganizationStatusBanner`/`OrganizationStatusCardMobile`.
- `AdminDashboardPage`/`MemberDashboardPage` **no deben confundirse con funcionalidad activa** — no aparecen en `AppRoutes`, no se navegan desde ningún botón, y no hay forma de llegar a ellas desde la UI actual.
