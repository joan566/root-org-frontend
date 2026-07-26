# ADR-012 — Refactorización de la Arquitectura Frontend (Flutter)

**Estado:** 🟢 Implementado (2026-07-26). Verificado con `flutter analyze` (0 errores) y `flutter test` (1/1 passed). Ver [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md) para el detalle completo de las 8 fases.
**Fecha:** 2026-07-26
**Prioridad:** Alta
**Impacto:** Alto (Todo el Frontend)
**Tipo:** Refactorización Arquitectónica
**Responsable:** Equipo Frontend

---

## Contexto

Tras finalizar la primera versión estable del Core del backend, el proyecto ha alcanzado un nivel de complejidad que hace necesario fortalecer también la arquitectura del frontend antes de continuar desarrollando nuevos módulos de negocio.

Actualmente el proyecto Flutter ya implementa una arquitectura basada en Features + Clean Architecture (ver [arquitectura-frontend.md](../02-arquitectura/arquitectura-frontend.md)), sin embargo, durante el crecimiento del proyecto comenzaron a aparecer problemas típicos de aplicaciones que evolucionan rápidamente:

- Existen pantallas con más de 1000-1500 líneas de código (ver inventario en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md)).
- Muchas responsabilidades se encuentran mezcladas dentro de un mismo archivo.
- La presentación todavía no está preparada para soportar correctamente Desktop y Mobile de forma independiente.
- Existen widgets específicos mezclados con widgets reutilizables.
- La navegación aún no refleja la arquitectura modular del producto.
- La estructura de carpetas no escala adecuadamente para los módulos que se implementarán posteriormente (Gestión Financiera, Inventario, Actividades, Préstamos, etc.).

Antes de comenzar cualquier nuevo módulo funcional, se realizará una refactorización completa de la arquitectura del frontend.

> **Importante**
>
> Esta decisión NO modifica la arquitectura del backend.
> Tampoco modifica la lógica de negocio existente.
> El objetivo es reorganizar completamente la capa de presentación para facilitar el crecimiento del producto durante los próximos años.

---

## Objetivos

- Mejorar la mantenibilidad del código.
- Reducir el tamaño de las clases.
- Separar responsabilidades correctamente.
- Preparar la aplicación para Desktop y Mobile.
- Evitar duplicación de código.
- Facilitar el desarrollo de nuevos módulos.
- Homogeneizar la arquitectura con el backend.

---

## Principios Arquitectónicos

### 1. Arquitectura por Features

La organización principal sigue siendo por Feature:

```
features/
    auth/
    dashboard/
    tenant/
    user/
    organization/
    financial/
    inventory/
```

Nunca se organizará el proyecto mediante carpetas globales tipo `pages/`, `widgets/`, `providers/`, `controllers/` a nivel raíz de `lib/`.

### 2. Clean Architecture

Cada Feature mantiene la separación `data/` / `domain/` / `presentation/`. No debe romperse esta separación.

### 3. La lógica no se duplica

Únicos por definición de contrato (nunca hay dos implementaciones paralelas de lo mismo):

- Casos de uso
- Providers
- Controllers
- Repositorios
- Servicios
- DTO
- Entidades

Desktop y Mobile únicamente cambian la representación visual, nunca la lógica.

### 4. Responsive por composición

No se crean dos aplicaciones. Una única aplicación con dos capas de presentación:

```
LoginScreen
  ↓ decide
  ↓
LoginDesktopView   o   LoginMobileView
```

Toda la lógica de negocio y de estado sigue siendo compartida entre ambas vistas.

---

## Arquitectura Objetivo (resumen)

```
lib/
  core/
  shared/
  features/
  main.dart
```

Cada Feature:

```
feature/
  data/
  domain/
  presentation/
```

Dentro de `presentation/`, por pantalla:

```
presentation/
  login/
    login_screen.dart
    mobile/
      login_mobile_view.dart
    desktop/
      login_desktop_view.dart
    widgets/
    dialogs/
    bottom_sheets/
    forms/
    state/
```

El detalle completo de esta estructura, con su justificación y ejemplos por feature existente, vive en [02-arquitectura-objetivo.md](./02-arquitectura-objetivo.md).

---

## Convenciones

| Elemento | Convención | Ejemplo |
|---|---|---|
| Rutas principales (Screens) | Sufijo `Screen`, nunca `Page` | `LoginScreen`, `ProfileScreen`, `DashboardScreen`, `OrganizationScreen` |
| Vistas por plataforma | Sufijo `DesktopView` / `MobileView` | `LoginDesktopView`, `LoginMobileView` |
| Widgets reutilizables | Sustantivo descriptivo, sin lógica de navegación | `UserCard`, `SearchBar`, `PermissionTable`, `RoleChip`, `FinancialSummaryCard` |
| Diálogos | Viven en `dialogs/` | — |
| Bottom Sheets | Viven en `bottom_sheets/` | — |
| Formularios grandes | Viven en `forms/` | — |
| Lógica de estado | Vive en `state/` | `login_controller.dart`, `auth_provider.dart`, `auth_injection.dart` |

### `shared/`

Carpeta nueva para elementos reutilizables **entre múltiples Features**:

```
shared/
  widgets/
  dialogs/
  layouts/
  navigation/
  forms/
  tables/
```

### `core/`

Deja de contener únicamente rutas y estilos; pasa a alojar infraestructura transversal:

```
core/
  routing/
  networking/
  services/
  storage/
  design_system/
  constants/
  extensions/
  utils/
  errors/
```

### Design System

Nuevo, dentro de `core/design_system/`:

```
design_system/
  colors/
  typography/
  spacing/
  radius/
  elevation/
  shadows/
  breakpoints/
  buttons/
  cards/
  dialogs/
  inputs/
  tables/
  navigation/
```

Todos los componentes reutilizables deben construirse utilizando este sistema.

---

## Objetivos de la Refactorización (contra el estado actual)

**Clases excesivamente grandes.** Hoy existen archivos por encima de 1000, 1200 y 1500 líneas (inventario completo en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md)). Esto no será aceptado en la nueva arquitectura: cada clase debe tener una única responsabilidad. Cuando una pantalla crezca demasiado debe dividirse usando Widgets, Forms, Dialogs, BottomSheets, Controllers y Views.

**Separación de responsabilidades.** Una Screen no debe: construir todo el UI, contener lógica de negocio, contener llamadas HTTP, contener validaciones complejas, ni contener widgets gigantes.

---

## Fases de Implementación

| Fase | Nombre | Entregable |
|---|---|---|
| 1 | Documentación y Planeación (**obligatoria**, sin tocar código) | Este ADR + documentos de arquitectura/navegación/responsive + plan de migración |
| 2 | Renombrado Arquitectónico | `*Page` → `*Screen` en todo el proyecto, referencias actualizadas |
| 3 | Nueva Estructura de Carpetas | Estructura objetivo creada (sin cambiar comportamiento) |
| 4 | Refactorización de Pantallas | División de pantallas grandes en widgets/forms/dialogs/bottom_sheets/state |
| 5 | Responsive Architecture | Implementación de `*DesktopView` / `*MobileView` |
| 6 | Shared Components | Migración de componentes reutilizables a `shared/` |
| 7 | Design System | Implementación de `core/design_system/` |
| 8 | Validación Final | Revisión completa contra los criterios de éxito |

Ver el detalle de cada fase, por feature, en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md).

---

## Restricciones

- No cambiar la lógica de negocio.
- No modificar contratos con el backend.
- No alterar APIs existentes.
- No introducir nuevas funcionalidades.
- No modificar casos de uso del dominio salvo que sea estrictamente necesario por la reorganización.
- Priorizar mantenibilidad y claridad sobre rapidez.

---

## Resultado Esperado

- Arquitectura modular por Features.
- Separación estricta de responsabilidades.
- Código significativamente más mantenible.
- Soporte limpio para Desktop y Mobile.
- Design System unificado.
- Componentes reutilizables.
- Navegación preparada para el crecimiento del producto.
- Base sólida para los próximos módulos (Estructura Organizacional, Gestión Financiera, Inventario, Actividades, Préstamos y futuros módulos del ecosistema).

## Documentos relacionados (Fase 1)

- [02-arquitectura-objetivo.md](./02-arquitectura-objetivo.md) — Documento de Arquitectura Frontend objetivo
- [03-arquitectura-navegacion.md](./03-arquitectura-navegacion.md) — Documento de Arquitectura de Navegación
- [04-estrategia-responsive.md](./04-estrategia-responsive.md) — Documento de Estrategia Responsive
- [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md) — Plan de migración por Features, lista de pantallas afectadas, lista de widgets reutilizables, lista de componentes a `shared/`, riesgos
