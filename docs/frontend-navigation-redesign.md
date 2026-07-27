# Rediseño del flujo de navegación — Fase 0 (análisis y propuesta)

> **Estado: 🟢 Implementado (Fases 1-4).** Fase 0 fue el entregable de análisis/propuesta (este documento); Fases 1-4 ya se ejecutaron — ver [shell-y-navegacion.md](./01-features/shell-y-navegacion.md), [panel-principal.md](./01-features/panel-principal.md) y [organizacion.md](./01-features/organizacion.md) para el estado final de cada pieza.
>
> **Actualización 2026-07-26 (Fase 5):** el flujo de login descrito en §1/§2 (0/1 organizaciones → entra directo; 2+ → `SelectTenantScreen`) fue superado por un gate obligatorio de selección de organización, sin importar cuántas tenga el usuario — y se agregó la regla de negocio "perfil completo requerido para crear/unirse a una organización". Ver [shell-y-navegacion.md](./01-features/shell-y-navegacion.md) y [perfil-y-usuario.md](./01-features/perfil-y-usuario.md#reglas-de-negocio) para el comportamiento vigente. El resto de este documento (mapa de navegación del shell, hallazgos de backend) sigue vigente sin cambios.
>
> **Alcance explícito:** esto es una reorganización de navegación/presentación sobre la arquitectura ya vigente de [ADR-012](./00-core/07-refactor-arquitectura-frontend/ADR-012-refactor-arquitectura-frontend.md). No se modifica `domain/`, `data/` ni casos de uso existentes, y no se rehace ADR-012.
>
> **Nota de convención:** el resto de la documentación del proyecto vive en `docs/00-core/NN-tema/` (números consecutivos, ADRs incluidos) y `docs/01-features/`. Este archivo se creó en `docs/` (raíz) porque así se pidió explícitamente. Si se prefiere, se puede mover a `docs/00-core/08-navegacion-modular/ADR-013-rediseno-navegacion.md` sin cambiar el contenido — es una decisión de forma, no de fondo.

## 1. Flujo actual (línea base verificada en código)

```
LoginScreen (auth/)
   │  MainApp decide LoginScreen vs MainLayout según AuthProvider.isLogged
   ▼
MainLayout (shell/) — Scaffold con bottom nav de 4 posiciones + Navigator interno
   │
   ├─ Tab 0 "Inicio"          → PersonalDashboardScreen   (ruta '/')
   ├─ Tab 1 "Organizaciones"  → TenantScreen              (AppRoutes.tenants)
   ├─ Tab 2 "Usuarios"        → (reservado, sin pantalla — index==2 no hace nada)
   └─ Tab 3 "Perfil"          → ProfileScreen             (AppRoutes.profile)

   FAB central → siempre CreateTenantScreen, sin importar el tab activo
```

Puntos verificados en código (no supuestos):

- **No existe el concepto de "tenant activo".** `LoginSesion` solo tiene `hasTenant: bool` (¿pertenece a al menos una organización?) y `User.tenants: List<UserTenant>` (todas las organizaciones a las que pertenece). No hay ningún campo que diga "cuál de ellas estoy usando ahora". `PersonalDashboardScreen` hoy resuelve esto tomando `tenantsList.first` a ciegas para calcular el rol mostrado — funciona por accidente mientras el usuario pertenezca a una sola organización.
- **"Selección de Tenant" no es un paso del flujo hoy** — es un tab más (`TenantScreen`, lista + buscador), no una pantalla gate entre login y dashboard. Si un usuario nuevo no tiene organizaciones, el propio `PersonalDashboardScreen` maneja ese caso mostrando `NoActiveOrganizationView` inline (no se navega a otro lado).
- **El switch de rutas es plano y centralizado** en `MainLayout._onGenerateRoute` — ya señalado como deuda en [03-arquitectura-navegacion.md](./00-core/07-refactor-arquitectura-frontend/03-arquitectura-navegacion.md) §2: "crecerá linealmente con cada módulo nuevo". Ese documento ya propone (§3.1) un `route_registry.dart` con registro por feature — nunca se implementó, y este es el momento natural de hacerlo, porque estamos a punto de agregar ~15 rutas nuevas.
- **Backend real disponible hoy** (verificado en `TenantApi`, `Tenant`, y [ADR-011](./00-core/06-api-integration/ADR-011-sistema-permisos.md)):
  - `Tenant` (entidad) solo tiene `id`, `name`, `description`, `code`. Sin lista de miembros, sin estructura, sin catálogo de roles.
  - `TenantApi` solo expone `createTenantWithOwner` y `joinTenant`. **No hay endpoint para listar miembros de una organización, actualizar sus datos, ni administrar roles.**
  - ADR-011 es explícito: *"No hay endpoints de administración de roles (crear roles personalizados, asignar/quitar permisos a un rol, ver el catálogo de permisos). Están explícitamente fuera de alcance de este sprint."* y *"`roles` es puramente informativo (...) el frontend no debe tomar decisiones de autorización basándose en estos strings."*
  - El mecanismo de autorización real (`AuthorizationPort`) existe en el backend pero **no se activa en ningún endpoint todavía** — se activará "cuando se retome el módulo Gestión Financiera (Sprint 4)".

Esto último es la restricción más importante de todo el documento: **buena parte del árbol de navegación que se pidió no tiene backend detrás hoy.** No es un problema de la propuesta — es información que faltaba para decidir qué se construye funcional y qué se construye como placeholder honesto.

## 2. Flujo propuesto

```
LoginScreen
   │
   ├─ 0 organizaciones → Dashboard General en estado "sin organización" (ya existe, se reutiliza)
   ├─ 1 organización   → se activa automáticamente, entra directo a Dashboard General
   └─ 2+ organizaciones → SelectTenantScreen (🆕) → elige activa → Dashboard General
   ▼
MainShellScreen (rediseño de MainLayout)
   Desktop: sidebar (Dashboard / Organización / Módulos / Administración / Configuración)
   Mobile:  header + bottom nav adaptativa
   │
   ├─ Dashboard General ✅ evoluciona PersonalDashboardScreen
   │
   ├─ Organización (🆕 feature `organization/`)
   │    ├─ Información                🆕 solo lectura (datos ya disponibles)
   │    ├─ Usuarios                   🕐 placeholder (sin backend)
   │    ├─ Roles                      🕐 placeholder (sin backend)
   │    └─ Estructura Organizacional  🕐 placeholder (sin backend ni dominio)
   │
   ├─ Módulos (agrupador de navegación, no una feature en sí)
   │    ├─ Gestión Financiera   🕐 placeholder (`financial_management/` vacío)
   │    ├─ Gestión de Préstamos 🕐 placeholder
   │    ├─ Inventario           🕐 placeholder (`inventory/` vacío)
   │    ├─ Actividades          🕐 placeholder (`activities/` vacío)
   │    └─ (futuros)
   │
   ├─ Administración (🆕 feature `administration/`, vacía salvo placeholder)
   │    ├─ Auditoría          🕐
   │    ├─ Integraciones      🕐
   │    └─ Herramientas admin 🕐
   │
   └─ Configuración (NO es feature nueva — reutiliza `user/`)
        ├─ Perfil        ✅ ProfileScreen, sin cambios
        ├─ Seguridad     ✅ SecurityCard + ChangePasswordScreen, sin cambios
        └─ Preferencias  ✅ PreferencesCard, sin cambios (incluye el toggle de tema ya implementado)
```

Leyenda: ✅ reutiliza sin cambios de lógica · 🆕 pantalla nueva con datos/lógica real · 🕐 placeholder "Próximamente" (sin backend hoy).

## 3. Mapa de navegación — detalle por sección

### 3.1 Organización

| Pantalla | ¿Hay backend hoy? | Qué se construye en esta fase |
|---|---|---|
| Información | Parcial — `Tenant.name/description/code` ya llegan en la sesión | Pantalla de **solo lectura** con esos 3 campos. No hay endpoint de actualización, así que no se agrega edición todavía (evita construir un formulario que no puede guardar nada). |
| Usuarios | No | Placeholder "Próximamente" con el mensaje de por qué (sin endpoint para listar miembros de un tenant). |
| Roles | No — ADR-011 lo excluye explícitamente | Placeholder. Cuando exista el endpoint de catálogo de roles, esta pantalla pasa a tener lógica real. |
| Estructura Organizacional | No — no hay modelo de dominio para esto | Placeholder. |

### 3.2 Módulos

Ninguno de los módulos listados (Financiero, Préstamos, Inventario, Actividades) tiene hoy dominio, datos ni backend. Se preparan como **carpetas de feature vacías** (`financial_management/`, `inventory/`, `activities/`), sin `domain/`/`data/` todavía, y una única pantalla placeholder por módulo enlazada desde "Módulos" y desde las tarjetas del Dashboard General. Esto es exactamente lo que ADR-012 ya dejó anotado para este momento (`ADR-012-plan-migracion.md`, tabla de features futuras: *"se crean directamente con la estructura objetivo desde el día 1 — ninguna migración, solo aplicar el patrón ya definido"*).

### 3.3 Administración

Auditoría/Integraciones/Herramientas: sin backend, sin dominio. Misma estrategia que Módulos — carpeta `administration/` con placeholder.

### 3.4 Configuración

**No se crea una feature `settings/` funcional todavía.** El nav "Configuración" apunta a las pantallas reales que ya existen en `user/presentation/profile/` (Perfil, Seguridad dentro del perfil + cambio de contraseña, Preferencias). Se prepara `settings/` como carpeta vacía reservada (sin mover nada de `user/`) para el día en que se decida separar "configuración de la cuenta" de "perfil". Mover código real de `user/` a `settings/` sería un cambio de arquitectura interna, no de navegación — está fuera del alcance de este documento y de la restricción "no rehacer ADR-012".

## 4. Nuevas pantallas necesarias

| Pantalla | Feature | Tipo |
|---|---|---|
| `SelectTenantScreen` | nuevo, dentro de `tenant/` (reutiliza datos de `TenantScreen`, agrega la acción "usar esta organización") | Funcional |
| `DashboardGeneralScreen` | `dashboard/` (evoluciona `PersonalDashboardScreen`, no se crea desde cero) | Funcional |
| `OrganizationInfoScreen` | `organization/` (nueva feature) | Funcional (solo lectura) |
| `OrganizationUsersScreen`, `OrganizationRolesScreen`, `OrganizationStructureScreen` | `organization/` | Placeholder |
| Una pantalla placeholder por módulo | `financial_management/`, `inventory/`, `activities/` (y futuras) | Placeholder |
| `AdministrationScreen` (única, con las 3 secciones como placeholder dentro) | `administration/` (nueva feature) | Placeholder |
| `MainShellScreen` | `shell/` (reemplaza `MainLayout`, mismo rol: layout persistente + navigator interno) | Funcional |

## 5. Pantallas que desaparecen

**Ninguna pantalla se elimina.** Es una reorganización, no una baja de funcionalidad:

- `MainLayout` se **reemplaza** por `MainShellScreen` (mismo rol, nuevo layout con sidebar en desktop).
- El tab "Usuarios" (reservado, sin pantalla, deuda ya documentada desde ADR-012) se **resuelve**: pasa a ser la sección "Organización → Usuarios" en el nuevo nav, en vez de seguir como un hueco sin destino.
- `TenantScreen` (lista de organizaciones) sigue existiendo — pasa a ser también el mecanismo real detrás de `SelectTenantScreen` para usuarios con 2+ organizaciones, y sigue disponible para cambiar de organización activa después del login.

## 6. Pantallas que se reutilizan sin cambios

`LoginScreen`, `RegisterScreen` y todo `auth/` · `TenantScreen`, `CreateTenantScreen`, `JoinTenantScreen` · `ProfileScreen`, `ChangePasswordScreen` · casi todos los widgets actuales de `PersonalDashboardScreen` (`HeroStateCard`, `MetricsSummaryBlock`, `QuickActionsGrid`, `SecurityManagementCard`, `FirstStepsChecklist`, `SmartRecommendationsSection`, `RecentActivityTimeline`) se recomponen dentro del nuevo `DashboardGeneralScreen` tal cual están.

Dos widgets cambian de propósito (no de código, de *dónde* y *para qué* se usan):

- `RecentOrganizationsList` (hoy: "aquí están tus organizaciones") → se reutiliza como acceso rápido para "cambiar de organización activa", porque ahora el dashboard gira alrededor de una sola organización activa, no de una lista.
- `UpcomingModulesSection` (hoy: vitrina decorativa de módulos futuros) → se convierte en las tarjetas reales de "Módulos" del Dashboard General, enlazando a cada placeholder de módulo.

## 7. Impacto en rutas

- `AppRoutes` crece de 7 a ~18 constantes. Dado que ADR-012 ya identificó esto como el momento de pasar a rutas registradas por feature (`03-arquitectura-navegacion.md` §3.1), esta fase implementa esa parte pendiente: cada feature nueva (`organization`, `administration`, cada módulo) declara sus propias rutas y se auto-registra en un `route_registry.dart` central en `core/routing/`, en vez de agregar 11 casos más al switch manual de `MainLayout`.
- El `NavigatorObserver` que hoy sincroniza "ruta activa → tab resaltado" con 3 `if` hardcodeados pasa a leer una tabla ruta→sección declarada por cada feature (mismo `03-arquitectura-navegacion.md` §3.2).
- Se mantiene sin cambios: dos Navigators (raíz para pre-sesión, interno para la app autenticada), `AppNavigator`, y el cuidado con `showDialog`/`showGeneralDialog` + `useRootNavigator`.

## 8. Impacto en estado global

Este es el único punto donde la frontera "no tocar domain/data existente" necesita una excepción explícita, y quiero que quede documentada antes de aprobar nada:

**No existe hoy ningún estado de "organización activa".** Para que "Selección de Tenant" y el nuevo Dashboard General tengan sentido, se necesita una pieza de estado nueva que recuerde cuál `UserTenant` está activo. Dos formas de resolverlo sin tocar código existente:

- **Recomendado:** un `TenantSessionController` nuevo (`ChangeNotifier`, mismo patrón que `ThemeController`), en `core/session/` (carpeta nueva), wireado en el `MultiProvider` de `main.dart` junto a `AuthProvider`/`ThemeController`. No modifica `AuthProvider`, `LoginSesion` ni `User` — es aditivo, vive al lado.
- Alternativa: agregar un campo `UserTenant? activeTenant` a `LoginSesion` — esto sí sería modificar una entidad existente (aunque solo se le agrega un campo opcional, sin romper nada que ya la use).

Uso de `roles` en la navegación (punto 4 de la propuesta original — "navegación basada en permisos"): dado que ADR-011 prohíbe expresamente tomar decisiones de autorización a partir de `roles`, cualquier filtrado de menú por rol en esta fase debe ser **cosmético únicamente** (ocultar ítems que probablemente no le sirven a ese usuario), nunca una garantía de seguridad — la puerta real sigue siendo el backend devolviendo 403. Sugiero implementar esto de forma mínima (ej. ocultar "Organización"/"Administración" para roles que no sean "Admin") y no más, hasta que el backend tenga un catálogo de roles real.

## 9. Riesgos

| Riesgo | Mitigación propuesta |
|---|---|
| Construir placeholders que se sientan "vacíos" y generen la sensación de app incompleta | Cada placeholder debe decir explícitamente qué falta y por qué (no un `SizedBox` en blanco) — mismo criterio ya usado en `NoActiveOrganizationView` |
| Agregar filtrado de nav por `roles` y que alguien lo lea como una capa de seguridad real | Documentarlo en el propio código (comentario) y en `docs/01-features/shell-y-navegacion.md`, citando ADR-011 |
| El switch de rutas centralizado vs. registro por feature es un cambio de mecánica de routing, no solo de contenido — puede introducir regresiones sutiles en la sincronización tab↔ruta | Migrar feature por feature, verificando con `flutter analyze` + captura visual después de cada una, mismo método usado en ADR-012 |
| `organization/` necesita su propio `domain`/`data` si "Información" va a leer datos reales — puede tentar a modelar de más para pantallas que hoy son placeholder | Solo modelar lo que ya existe (`Tenant.name/description/code`, ya disponible vía `AuthProvider.session`) — no crear entidades para Usuarios/Roles/Estructura hasta que haya backend real |

## 10. Fases de ejecución propuestas (ajustadas con los hallazgos de arriba)

1. **Fase 0 (este documento)** — sin cambios de código. ✅
2. **Fase 1 — Shell**: `MainShellScreen`, sidebar desktop, bottom nav adaptativa mobile, `route_registry.dart` + rutas por feature. ✅
3. **Fase 2 — Dashboard General**: recomponer `PersonalDashboardScreen` → `DashboardGeneralScreen`, agregar header de organización activa y tarjetas de módulos reales (a partir de `UpcomingModulesSection`). ✅
4. **Fase 3 — Organización**: `organization/` con `OrganizationInfoScreen` (real) + 3 placeholders. ✅
5. **Fase 4 — Placeholders de módulos**: `financial_management/`, `inventory/`, `activities/`, `administration/`, `settings/`. ✅ — cada una es solo `lib/features/<nombre>/presentation/.gitkeep` (mismo patrón que las carpetas de `core/design_system/` que ADR-012 dejó reservadas), **sin pantalla ni ruta propia**: agregar una pantalla, aunque fuera un placeholder, ya es "implementar" algo — la sección "Módulos" del nav sigue sirviendo el `ComingSoonScreen` genérico registrado en Fase 1 hasta que cada módulo tenga trabajo real que justifique separarlo.
6. **Estado global**: `TenantSessionController` + `SelectTenantScreen` — hecho en paralelo a la Fase 1. ✅

## 11. Puntos abiertos (no bloquean escribir este documento, sí bloquean empezar la Fase 1)

1. ¿"Información" de Organización debería permitir edición si en el futuro aparece el endpoint, o se deja explícitamente fuera de alcance por ahora? (Propuesta: fuera de alcance — solo lectura.)
2. ¿El filtrado de nav por `roles` (cosmético) se implementa ya en Fase 1, o se deja para cuando el backend tenga permisos reales activados (Sprint 4 del backend)? (Propuesta: dejarlo para cuando el backend lo soporte, para no construir una capa de UX que luego haya que rehacer.)
3. ¿Mover este documento a `docs/00-core/08-navegacion-modular/ADR-013-...md` para mantener el índice numerado, o queda en `docs/` como está?
