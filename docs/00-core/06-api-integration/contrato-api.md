# Contrato de API — Referencia General

Vista completa de todos los endpoints que consume el frontend. Para el detalle del sistema de permisos/roles (ADR-011), ver [ADR-011-sistema-permisos.md](./ADR-011-sistema-permisos.md) y su [plan de refactor](./ADR-011-plan-refactor-frontend.md).

## Convenciones generales

- **Base URL**: `http://192.168.0.104:8080` (hardcodeada en cada `*Api`; `TenantApi` usa `.../tenant` como prefijo).
- **Auth**: `Authorization: Bearer <token>` en cada endpoint que lo requiere (columna "Auth" abajo).
- **Content-Type**: `application/json` en requests con body.
- **Shape de error estándar** (cualquier status no-2xx):
  ```json
  {
    "status": 400,
    "error": "VALIDATION_ERROR",
    "message": "Texto en español listo para mostrar al usuario.",
    "path": "/ruta/invocada",
    "timestamp": "2026-07-25T10:15:30"
  }
  ```
  Códigos conocidos de `error`: `VALIDATION_ERROR` (400), `AUTH_ERROR` (401), `FORBIDDEN_ERROR` (403 — ver ADR-011, aún no disparado por ningún endpoint), `NOT_FOUND` (404), `INTERNAL_ERROR` (500).
- El frontend traduce cualquier error HTTP a `ApiException(statusCode, errorCode, message)` — ver [arquitectura-frontend.md](../02-arquitectura/arquitectura-frontend.md#capa-de-api).

## Auth (`AuthApi`, sin prefijo)

| Método | Ruta | Auth | Body request | Descripción |
|---|---|---|---|---|
| POST | `/auth/login` | No | `{ email, password }` | Inicia sesión. Devuelve `token`, `hasTenant`, `user` (con `userTenantInfos`, `userEmail`). |
| POST | `/auth/users/create` | No | `{ name, phoneNumber, email, password }` | Registra una cuenta nueva. |
| POST | `/auth/forgot-password` | No | `{ email }` | Envía código de recuperación al correo. |
| POST | `/auth/verify-code` | No | `{ email, code }` | Verifica el código; devuelve `resetToken`. |
| POST | `/auth/reset-password` | No | `{ resetToken, newPassword, confirmPassword }` | Establece la nueva contraseña. |
| POST | `/auth/users/change-password` | Sí | `{ oldPassword, newPassword, confirmPassword }` | Cambia la contraseña de la sesión activa. |

## User (`UserApi`, sin prefijo)

| Método | Ruta | Auth | Body/Query | Descripción |
|---|---|---|---|---|
| GET | `/users/profile` | Sí | Query `id` | Perfil del usuario. Respuesta bajo la clave `userInfo`. |
| POST | `/users/update-profile` | Sí | `{ userId, name, lastName, document, phoneNumber, dateOfBirth, gender }` | Actualiza el perfil. Respuesta bajo `userInfo`. |

## Tenant (`TenantApi`, prefijo `/tenant`)

| Método | Ruta | Auth | Body request | Descripción |
|---|---|---|---|---|
| POST | `/tenant/create-with-owner` | Sí | `{ name, description, userId }` | Crea una organización; el creador recibe `roles: ["Admin"]` automáticamente. Respuesta con `tenantInfo` + `userTenantInfo`. |
| POST | `/tenant/join-tenant` | Sí | `{ userId, tenantCode }` | Se une a una organización por código. **No** acepta `role` (contrato cambiado en ADR-011) — siempre asigna `roles: ["Member"]`. |

## Claves de respuesta — mapa de correcciones

Estas claves tuvieron nombres distintos entre la documentación antigua y el backend real; ya están alineadas en el código actual:

| Clave antigua/documentada | Clave real usada por el frontend | Dónde |
|---|---|---|
| `userTenants` | `userTenantInfos` | `user.userTenantInfos[]` en login/perfil |
| `email` | `userEmail` | objeto `user`/`userInfo` |
| `user` (raíz) | `userInfo` | `GET /users/profile`, `POST /users/update-profile` |
| `tenant` (raíz) | `tenantInfo` | `POST /tenant/create-with-owner` |
| `role` (string) | `roles` (array) | cada objeto `userTenantInfo` |

## No disponible todavía

- Endpoint para listar permisos de un usuario o consultar "¿puedo hacer X?" — la verificación de permisos es interna del backend.
- Endpoints de administración de roles (crear roles personalizados, catálogo de permisos).
- Cualquier endpoint del módulo de Gestión Financiera (aportes, préstamos, transferencias) — las pantallas `AdminDashboardPage`/`MemberDashboardPage` son mockups visuales sin API detrás, ver [requisitos-funcionales.md](../03-requisitos/requisitos-funcionales.md#fuera-de-alcance-actual-mockups-sin-conectar).
