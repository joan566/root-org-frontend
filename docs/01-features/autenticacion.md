# Feature: Autenticación (`lib/features/auth`)

## Responsabilidad

Login, registro, recuperación de contraseña, y el estado de sesión global de toda la app (`AuthProvider`). Es la única feature que expone estado reactivo compartido — todas las demás lo consumen (`context.read/watch<AuthProvider>()`).

## Pantallas (`presentation/pages/`)

| Pantalla | Ruta de acceso | Descripción |
|---|---|---|
| `LoginScreen` | `home` de `MaterialApp` (no logueado) | Formulario de login + enlaces a registro y "olvidé mi contraseña" |
| `RegisterScreen` | `Navigator.pushNamed(context, "/register")` desde login | Formulario de registro + vista de éxito |
| `ForgotPasswordScreen` | `Navigator.push` (MaterialPageRoute) desde login | Paso 1 de recuperación: solicitar código |
| `VerificationCodeScreen` | Push desde `ForgotPasswordScreen` | Paso 2: verificar código, obtiene `resetToken` |
| `ResetPasswordScreen` | Push desde `VerificationCodeScreen` | Paso 3: nueva contraseña |

## Estado

- `AuthProvider` (`presentation/provider/auth_provider.dart`): `ChangeNotifier` con `session: LoginSesion?`, `isLogged`. Métodos: `login()`, `logout()`, `updateUser()`, `refreshSession()`.
- Cada pantalla usa un `Controller` propio y desechable (`LoginController`, `RegisterController`, `ForgotPasswordController`) instanciado en `initState()` vía `AuthInjection`.

## Casos de uso relacionados

Ver [casos de uso — autenticación](../00-core/04-casos-de-uso/authentication/casos-de-uso.md).

## Puntos de atención

- `RegisterScreen` vuelve a login con `Navigator.pop(context)`, no con una ruta nombrada `/login` (no existe como ruta registrada).
- `ForgotPasswordController` maneja los 3 pasos de recuperación con un único controller compartido (`sendCode`, `verifyCode`, `resetPassword`), inyectado una sola vez vía `AuthInjection.forgotPassword()` y reutilizado a través de las 3 pantallas navegadas en cadena.
- `AuthApi` no distingue login/registro exitoso de un usuario "no logueado a propósito" — cualquier respuesta no-2xx se traduce a `ApiException`.
