# Modelo de Dominio

Entidades de `domain/entities/` — clases planas, sin dependencia de Flutter ni de JSON, resultado de mapear los `Model` de la capa `data/`. Organizadas por feature.

## Auth

### `User` (`auth/domain/entities/user.dart`)
Usuario del sistema. Campos: `id`, `name`, `lastName?`, `document?`, `dateOfBirth?`, `gender?`, `email`, `phoneNumber`, `status`, `profileStatus`, `tenants: List<UserTenant>`, `createdAt`, `updatedAt`.

### `LoginSesion` (`auth/domain/entities/login_sesion.dart`)
La sesión activa, guardada en `AuthProvider`. Campos: `token` (JWT), `hasTenant` (mutable — se actualiza en memoria al crear/unirse a una organización), `user: User`.

### `UserTenant` (`auth/domain/entities/user_tenant.dart`)
La relación usuario↔organización. Campos: `id`, `tenant: Tenant`, `userId`, `roles: List<String>`, `status`.
**`roles` es informativo únicamente** — un usuario puede tener varios roles en la misma organización; el nombre del rol no determina qué puede hacer en el frontend (esa validación es del backend). Ver [ADR-011](../06-api-integration/ADR-011-sistema-permisos.md). Antes de ADR-011 este campo era `role: String` (uno solo).

### `RegisterUser` (`auth/domain/entities/register_user.dart`)
Resultado de `POST /auth/users/create`. Campos: `successfully`, `message` (sin datos del usuario creado).

## Tenant

### `Tenant` (`tenant/domain/entities/tenant.dart`)
Una organización. Campos: `id`, `name`, `description`, `code` (código de invitación único).

### `JoinTenant` (`tenant/domain/entities/join_tenant.dart`)
Resultado de `POST /tenant/join-tenant`. Campos: `successfully`, `message`, `userTenant: UserTenant` (la nueva relación creada, con `roles: ["Member"]`).

### `RegisterTenantWithOwner` (`tenant/domain/entities/register_tenant_with_owner.dart`)
Resultado de `POST /tenant/create-with-owner`. Campos: `successfully`, `message`, `tenant: Tenant` (la organización creada), `userTenant: UserTenant` (la relación del creador, con `roles: ["Admin"]`).

## User (perfil)

### `GetUser` (`user/domain/entities/get_user.dart`)
Resultado de `GET /users/profile`. Campos: `successfully`, `message`, `user: User`.

### `UpdateProfile` (`user/domain/entities/update_profile.dart`)
Resultado de `POST /users/update-profile`. Campos: `successfully`, `message`, `user: User`.

### `ChangePassword` (`user/domain/entities/change_password.dart`)
Resultado de `POST /auth/users/change-password`. Campos: `successfully`, `message` (sin datos de usuario).

> Nota: existió un tercer par `Profile`/`ProfileModel`/`ProfileMapper` en `user/`, con un shape casi idéntico a `GetUser` pero usando la clave JSON obsoleta `userTenants`. Se confirmó que ningún flujo real lo instanciaba (`UserRepositoryAdapter` siempre usó `GetUserModel`/`UpdateProfileModel`) y se eliminó como parte del refactor de ADR-011.

## Diagrama de relaciones

```
LoginSesion
 ├── token: String
 ├── hasTenant: bool
 └── user: User
      ├── id, name, email, phoneNumber, status, profileStatus, ...
      └── tenants: List<UserTenant>
           ├── tenant: Tenant (id, name, description, code)
           ├── roles: List<String>   ← informativo, ver ADR-011
           └── status: String
```

`User` y `UserTenant` son las entidades compartidas entre auth, tenant y user — se construyen siempre a partir de la misma `UserModel`/`UserTenantModel` (`auth/data/models/`), sin importar si el JSON vino de login, perfil, join-tenant o create-with-owner.
