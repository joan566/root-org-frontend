# ADR-011: Sistema de Permisos (roles informativos, autorización en backend)

## Contexto

El backend introdujo un sistema de permisos por tenant. Como parte de ese cambio, el campo `role` (string único: `"ADMIN"` o `"MEMBER"`) desaparece de todas las respuestas que devuelven la relación usuario↔organización. En su lugar, cada relación trae `roles` (array de strings), porque un usuario puede tener varios roles en el mismo tenant.

De paso, el backend corrigió tres inconsistencias que ya existían entre la documentación vieja y el código real (`userTenants`→`userTenantInfos`, `email`→`userEmail`, `user`/`tenant`→`userInfo`/`tenantInfo`). No son cambios de este sprint, pero afectan cómo se parsean las respuestas y quedan documentados abajo junto con el resto.

## Principio de consumo obligatorio

**`roles` es puramente informativo** (para mostrar en UI, ej. un badge "Admin"). El frontend **no debe** tomar decisiones de autorización basándose en estos strings — ni para mostrar/ocultar botones críticos ni para inferir capacidades. La validación real vive en el backend vía permisos, y el nombre de un rol puede no reflejar las capacidades reales de un rol personalizado que un tenant cree en el futuro.

Cualquier lógica en el frontend que hoy infiera capacidades a partir de `role` (ej. `role == 'ADMIN' ? tieneAccesoTotal : no`) debe eliminarse o quedar explícitamente marcada como una aproximación cosmética, nunca como una puerta de autorización real.

## Endpoints afectados

### `POST /auth/login`

Request sin cambios. Response — clave correcta es `userTenantInfos` (no `userTenants`), y `userEmail` (no `email`):

```json
{
  "successfully": true,
  "message": "Inicio de sesion exitoso",
  "token": "eyJhbGciOiJIUzI1Ni...",
  "hasTenant": true,
  "user": {
    "id": 1,
    "name": "John",
    "lastName": "Doe",
    "document": "12345678",
    "dateOfBirth": "1990-01-01",
    "gender": "Masculino",
    "userEmail": "usuario@gmail.com",
    "phoneNumber": "123456789",
    "status": "Activo",
    "profileStatus": "Completo",
    "userTenantInfos": [
      {
        "id": 1,
        "tenantInfo": { "id": 1, "name": "Empresa A", "description": null, "code": "ORG-123" },
        "userId": 1,
        "roles": ["Admin"],
        "status": "ACTIVE"
      }
    ],
    "createdAt": "2026-07-25",
    "updatedAt": "2026-07-25"
  }
}
```

Antes: cada objeto del array tenía `"role": "ADMIN"`. Ahora: `"roles": ["Admin"]` (array, nombres tal como los configuró el sistema/tenant, no en mayúsculas fijas).

### `GET /users/profile`

Clave raíz es `userInfo` (no `user`):

```json
{
  "successfully": true,
  "message": "Se encontro la informacion del usuario con exito.",
  "userInfo": {
    "id": 1,
    "name": "John",
    "lastName": "Doe",
    "userEmail": "usuario@gmail.com",
    "phoneNumber": "123456789",
    "userTenantInfos": [
      {
        "id": 1,
        "tenantInfo": { "name": "Mi Empresa", "code": "ABC-123" },
        "userId": 1,
        "roles": ["Admin"],
        "status": "ACTIVE"
      }
    ]
  }
}
```

### `POST /users/update-profile`

Misma forma que `GET /users/profile` (usa la misma clase `UserInfo`, clave raíz `userInfo`, mismo cambio `role`→`roles`).

### `POST /tenant/create-with-owner`

Request sin cambios. Response — clave correcta es `tenantInfo` (no `tenant`):

```json
{
  "successfully": true,
  "message": "Se creo Mi Nueva Empresa con exito",
  "tenantInfo": {
    "id": 1,
    "name": "Mi Nueva Empresa",
    "description": null,
    "code": "XYZ-789"
  },
  "userTenantInfo": {
    "id": 1,
    "userId": 1,
    "roles": ["Admin"],
    "status": "ACTIVE"
  }
}
```

El creador de la organización siempre recibe `"roles": ["Admin"]` (acceso total, sembrado automáticamente).

### `POST /tenant/join-tenant` — cambio de contrato, no solo de forma

El campo `role` **ya no existe en el request** y ya no se acepta aunque se envíe:

```json
// ANTES
{ "userId": 1, "tenantCode": "ORG-123", "role": "MEMBER" }

// AHORA
{ "userId": 1, "tenantCode": "ORG-123" }
```

Si el frontend sigue enviando `role`, el backend lo ignora (el DTO de request ya no lo mapea). Esto no es cosmético: antes cualquier usuario podía enviar `"role": "ADMIN"` y el backend se lo concedía sin validar — era una escalada de privilegios real. Ahora el usuario que se une por código siempre recibe el rol base `Member` de esa organización, sin excepción.

Response:

```json
{
  "successfully": true,
  "message": "Se ingreso con exito a Empresa Demo",
  "userTenantInfo": {
    "id": 1,
    "tenantInfo": { "name": "Empresa Demo", "code": "ORG-123" },
    "userId": 1,
    "roles": ["Member"],
    "status": "ACTIVE"
  }
}
```

## Nuevo shape de error 403 (todavía no se dispara en ningún endpoint actual)

Mismo formato de error estándar ya conocido, con `status: 403`:

```json
{
  "status": 403,
  "error": "FORBIDDEN_ERROR",
  "message": "No tienes permiso para realizar esta acción.",
  "path": "/algun-endpoint-futuro",
  "timestamp": "2026-07-25T10:15:30"
}
```

El código existe en el backend (`GlobalExceptionHandler`) pero ningún endpoint actual lo dispara todavía — el mecanismo de verificación de permisos (`AuthorizationPort`) está construido, pero se empezará a usar cuando se retome el módulo Gestión Financiera (Sprint 4). El frontend debe manejar `FORBIDDEN_ERROR` (403) desde ya en su manejador genérico de errores, junto a `VALIDATION_ERROR` (400), `AUTH_ERROR` (401) y `NOT_FOUND` (404), para no tener que retocar ese código más adelante.

## Qué NO cambió

- El shape de error estándar (`status`, `error`, `message`, `path`, `timestamp`) — solo se sumó un código nuevo.
- El JWT sigue enviándose igual (`Authorization: Bearer <token>`), con la misma expiración.
- `TenantInfo` (`id`, `name`, `description`, `code`) no cambió.
- Los demás endpoints de auth (`forgot-password`, `verify-code`, `reset-password`, `change-password`) no fueron tocados.

## Qué NO está disponible todavía

- No hay endpoint para listar los permisos de un usuario ni para consultar "¿puedo hacer X?" desde el frontend — la verificación de permisos es interna del backend.
- No hay endpoints de administración de roles (crear roles personalizados, asignar/quitar permisos a un rol, ver el catálogo de permisos). Están explícitamente fuera de alcance de este sprint.
- El JWT decodificado en cliente (si se hace por algún motivo) trae `userTenants[].roles` como array de nombres — informativo, mismo caveat que arriba: no usarlo para decidir autorización en el cliente.

## Recomendación de consumo

- En cualquier componente que hoy lea `userTenant.role` (string), cambiar a leer `userTenant.roles` (array) y decidir cómo mostrarlo (ej. `roles.join(", ")` o un badge por cada uno).
- En el flujo de "unirse a organización", quitar el selector/campo de rol del formulario — ya no tiene efecto.
- Agregar manejo de `403 FORBIDDEN_ERROR` al interceptor/manejador global de errores HTTP, junto a los que ya manejan 400/401/404.
- Revisar cualquier código que dependiera de las claves `userTenants`, `user` (en perfil) o `tenant` (en create-with-owner) — corregir a `userTenantInfos`, `userInfo` y `tenantInfo` respectivamente.

## Referencias

- Plan de ejecución para este frontend: [ADR-011-plan-refactor-frontend.md](./ADR-011-plan-refactor-frontend.md)
