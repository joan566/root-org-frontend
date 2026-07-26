# Casos de Uso — Organizaciones (Tenant)

## CU-04: Crear organización

**Actor**: usuario autenticado.
**Precondición**: sesión activa.
**Flujo principal**:
1. Desde el panel principal (accesos rápidos), la lista de organizaciones, o el botón flotante de `MainLayout`, el usuario abre `CreateTenantScreen`.
2. Ingresa nombre y descripción → `POST /tenant/create-with-owner`.
3. El backend crea la organización y asigna al creador `roles: ["Admin"]` automáticamente (no es una elección del usuario).
4. La respuesta trae el código de invitación único de la organización, que se muestra en una vista de éxito para compartir.
5. `session.hasTenant` y `user.tenants` se actualizan en memoria y se llama `AuthProvider.refreshSession()` para que el resto de la app (ej. el panel principal) refleje el cambio de inmediato.
6. Al continuar, `pushReplacementNamed(context, "/dashboard")` — dentro del navigator interno de `MainLayout`, esta ruta no está registrada explícitamente pero cae en el caso `default` de su `onGenerateRoute`, que construye el panel principal.
**Postcondición**: nueva organización creada; el usuario es su propietario (`Admin`).

Pantalla: `CreateTenantScreen`. Wiring: `TenantInjection.registerTenantWithOwnerController()`.

## CU-05: Unirse a una organización por código

**Actor**: usuario autenticado con un código de invitación válido.
**Precondición**: sesión activa; código de invitación proporcionado por un administrador de la organización.
**Flujo principal**:
1. El usuario abre `JoinTenantScreen` (desde el panel principal o la lista de organizaciones) e ingresa el código (puede pegarlo desde el portapapeles).
2. `POST /tenant/join-tenant` con `{ userId, tenantCode }` — **sin** campo de rol; el formulario no ofrece elegirlo, porque el backend siempre asigna el rol base `Member` (antes de ADR-011, el frontend enviaba `"role": "MEMBER"` hardcodeado, un campo que el backend hoy ignora explícitamente).
3. Si es exitoso, se actualiza `session.hasTenant`/`user.tenants` en memoria + `AuthProvider.refreshSession()`, y se muestra un diálogo de bienvenida.
4. Al continuar, el diálogo se cierra y la pantalla vuelve a la anterior (`JoinTenantScreen` se saca de la pila del navigator interno de `MainLayout`).
**Flujo alterno**: código inválido/inexistente → diálogo de error con el mensaje del backend.
**Postcondición**: el usuario queda vinculado a la organización con rol `Member`.

Pantalla: `JoinTenantScreen`. Wiring: `TenantInjection.joinTenantController()`.

## CU-06: Ver mis organizaciones

**Actor**: usuario autenticado.
**Precondición**: sesión activa (con o sin organizaciones).
**Flujo principal**:
1. El usuario navega a la pestaña "Organizaciones" del bottom nav.
2. `TenantScreen` lista las organizaciones ya presentes en `session.user.tenants` (no dispara una consulta nueva al backend — usa lo que ya trae la sesión desde login/perfil).
3. Cada tarjeta muestra nombre, código, estado y los roles del usuario en esa organización (un badge por rol).
4. Desde aquí puede acceder a crear o unirse a una nueva organización; al volver de esas pantallas, la lista se refresca (`_loadData()`) leyendo de nuevo la sesión.
**Postcondición**: ninguna (solo lectura).

Pantalla: `TenantScreen`.
