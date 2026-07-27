# Feature: Perfil y Usuario (`lib/features/user`)

## Responsabilidad

Consulta y edición del perfil del usuario autenticado, y cambio de contraseña. No maneja login/registro (eso es `auth/`) ni organizaciones (eso es `tenant/`), aunque muestra las organizaciones del usuario (leídas desde `User.tenants`, provisto por `auth/`).

## Pantallas (`presentation/<screen>/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `ProfileScreen` | `AppRoutes.profile` (navigator interno de `MainLayout`, tab "Perfil") | Vista principal del perfil |
| `ChangePasswordScreen` | `AppRoutes.changePassword` | Cambio de contraseña |

## Widgets de perfil (`presentation/profile/widgets/`)

Composición de `ProfileScreen`: `ProfileHeader` + `ProfileAvatar` (con anillo de progreso, `AvatarProgressPainter`), `ProfileStats`, `ProfileCompletionCard`, `PersonalInfoCard`, `ContactInfoCard`, `OrganizationsSection` (lista de `UserTenant` con `RoleChip` — un chip por rol — y `StatusChip`), `SecurityCard`, `RecentActivityCard`, `PreferencesCard`, `LogoutCard`. La edición se hace en una hoja inferior modal, `EditProfileBottomSheet`.

## Estado

Sin `ChangeNotifier` propio — `ProfileScreen` es `StatefulWidget` con `loading`/error local, y sincroniza los cambios hacia el estado global llamando `context.read<AuthProvider>().updateUser(...)` después de cada operación exitosa (ver perfil, editar perfil).

Controllers (vía `UsersInjection`): `GetUserController`, `UpdateProfileController`, `ChangePasswordController`.

## Casos de uso relacionados

Ver [casos de uso — user](../00-core/04-casos-de-uso/user/casos-de-uso.md).

## Reglas de negocio

- **Perfil completo requerido para crear/unirse a una organización** (2026-07-26): un usuario no puede crear ni unirse a una organización si su perfil está incompleto. La fuente única de verdad es `User.isProfileComplete` (getter calculado en `auth/domain/entities/user.dart`), que exige 6 campos no vacíos: `name`, `lastName`, `document`, `phoneNumber`, `dateOfBirth`, `gender` — los mismos que exige `EditProfileBottomSheet` para guardar. **No** se usa `User.profileStatus` (string cruda del backend) para esta decisión: su formato es inconsistente entre lo que compara el código (`'COMPLETED'`) y el ejemplo de payload documentado en [ADR-011](../00-core/06-api-integration/ADR-011-sistema-permisos.md) (`'Completo'`) — nunca coinciden, así que no es confiable como gate. `profileStatus` se conserva en la entidad solo como dato informativo del backend.
- El guard vive en `CreateTenantScreen`/`JoinTenantScreen` (no en cada botón que navega hacia ellas) — ver [organizaciones.md](./organizaciones.md#puntos-de-atención).

## Puntos de atención

- "Solicitar eliminación de cuenta" en `LogoutCard` es un placeholder visual sin lógica (`onTap` vacío).
- El `Profile`/`ProfileModel`/`ProfileMapper` que existía en paralelo a `GetUser`/`UpdateProfile` era código muerto (nunca instanciado) y se eliminó — ver [modelo-dominio.md](../00-core/05-dominio/modelo-dominio.md).
