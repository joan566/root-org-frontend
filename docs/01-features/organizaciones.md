# Feature: Organizaciones / Tenant (`lib/features/tenant`)

## Responsabilidad

Crear organizaciones, unirse a ellas por código de invitación, y listarlas. El concepto de "tenant" es la unidad multi-organización de SUMKEYA (ver [vision-frontend.md](../00-core/01-vision/vision-frontend.md)).

## Pantallas (`presentation/<screen>/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `TenantScreen` | `AppRoutes.tenants` (accesos rápidos del Dashboard) | Lista de organizaciones del usuario, con búsqueda |
| `CreateTenantScreen` | `AppRoutes.createTenant` (accesos rápidos) | Formulario de creación + vista de éxito con código de invitación |
| `JoinTenantScreen` | `AppRoutes.joinTenant` (accesos rápidos) | Formulario de código de invitación + diálogo de bienvenida |
| `SelectTenantScreen` | `presentation/select_tenant/` — se muestra antes del shell, no tiene ruta nombrada | **Nuevo (Fase 1 del rediseño de navegación, 2026-07-26).** Paso "Selección de Tenant" del login: aparece solo cuando el usuario pertenece a 2+ organizaciones y ninguna fue elegida como activa (`TenantSessionController.resolveActive`). Reutiliza `OrganizationCard`; al tocar una organización, la marca como activa y navega a `MainShellScreen`. Ver [shell-y-navegacion.md](./shell-y-navegacion.md). |

> **Nota:** desde ADR-012, el tab "Organizaciones" del bottom nav ya no existe (reemplazado por las 5 secciones del nuevo shell — ver [shell-y-navegacion.md](./shell-y-navegacion.md)). `TenantScreen` sigue activa y registrada, alcanzable desde los accesos rápidos del Dashboard General, pero no es uno de los 5 destinos principales del nav.

## Estado

Sin estado propio persistente — cada pantalla lee `context.read<AuthProvider>().session` para obtener las organizaciones actuales y muta `session.hasTenant`/`user.tenants` directamente al crear/unirse, seguido de `authProvider.refreshSession()` para propagar el cambio a quien esté escuchando (ej. el panel principal).

Controllers (vía `TenantInjection`): `RegisterTenantWithOwnerController`, `JoinTenantController`.

## Casos de uso relacionados

Ver [casos de uso — tenant](../00-core/04-casos-de-uso/tenant/casos-de-uso.md).

## Puntos de atención

- El formulario de "unirse" no tiene (ni debe tener) selector de rol — el backend siempre asigna `Member`. Antes de ADR-011 el frontend enviaba `"role": "MEMBER"` hardcodeado; era una escalada de privilegios latente si el backend hubiese confiado en ese valor.
- `JoinTenantScreen` abre su diálogo de éxito con `showGeneralDialog` (que por defecto usa el navigator raíz, no el interno de `MainLayout` donde vive la pantalla) — el cierre del diálogo y el `pop` de la propia pantalla usan navigators capturados por separado para evitar dejar la app en una pantalla en blanco.
- `CreateTenantScreen` navega a `"/dashboard"` al terminar; esa ruta no está registrada explícitamente en el navigator interno de `MainLayout`, pero cae en su caso `default` (que construye el panel principal) — funciona, aunque no es autoexplicativo si se lee aislado.
