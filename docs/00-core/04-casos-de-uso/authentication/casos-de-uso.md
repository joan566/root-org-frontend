# Casos de Uso — Autenticación

## CU-01: Registrar cuenta

**Actor**: visitante sin cuenta.
**Precondición**: ninguna.
**Flujo principal**:
1. El usuario abre "Crear cuenta" desde `LoginPage` (`Navigator.pushNamed(context, "/register")`).
2. Completa nombre, teléfono, correo y contraseña; acepta términos.
3. El frontend llama `POST /auth/users/create`.
4. Si la respuesta es exitosa, se muestra una vista de confirmación con un botón "Ir al inicio de sesión" que hace `Navigator.pop(context)` (vuelve a `LoginPage`, que quedó debajo en la pila).
**Flujo alterno**: si el backend responde con error (correo duplicado, validación), se muestra el mensaje en una tarjeta de error inline; el usuario permanece en el formulario.
**Postcondición**: cuenta creada en el backend; el usuario **no** queda autenticado automáticamente — debe iniciar sesión.

Pantalla: `RegisterPage`. Wiring: `AuthInjection.register()`.

## CU-02: Iniciar sesión

**Actor**: usuario registrado.
**Precondición**: cuenta existente.
**Flujo principal**:
1. El usuario ingresa correo y contraseña en `LoginPage`.
2. El frontend llama `POST /auth/login`.
3. Si es exitoso, `AuthProvider.login(session)` guarda la sesión (token, `hasTenant`, usuario con sus organizaciones) y notifica a los listeners.
4. `MainApp` (en `main.dart`), que escucha `AuthProvider` con un `Consumer`, cambia automáticamente su `home` de `LoginPage` a `MainLayout` — no hay una navegación imperativa explícita hacia el dashboard.
**Flujo alterno**: credenciales inválidas → mensaje de error inline, el usuario permanece en `LoginPage`.
**Postcondición**: sesión activa en memoria; acceso a las pantallas autenticadas vía `MainLayout`.

Pantalla: `LoginPage`. Wiring: `AuthInjection.login()`.

## CU-03: Recuperar contraseña olvidada

**Actor**: usuario registrado que no recuerda su contraseña.
**Precondición**: cuenta existente con correo válido.
**Flujo principal** (3 pantallas encadenadas):
1. **Solicitar código** (`ForgotPasswordPage`): el usuario ingresa su correo → `POST /auth/forgot-password`. Si es exitoso, navega a la verificación.
2. **Verificar código** (`VerificationCodePage`): el usuario ingresa el código de 6 dígitos recibido por correo → `POST /auth/verify-code`. La respuesta trae un `resetToken`, que se captura y se pasa (no el código ni el correo) a la siguiente pantalla. El usuario también puede pedir reenvío del código desde aquí (mismo endpoint que el paso 1), con su propio loading/error independiente.
3. **Establecer nueva contraseña** (`ResetPasswordPage`): el usuario define y confirma su nueva contraseña → `POST /auth/reset-password` enviando **solo** `resetToken` + `newPassword` + `confirmPassword` (sin correo ni código — ver [ADR-011](../../06-api-integration/ADR-011-sistema-permisos.md) para el porqué de este contrato). Al finalizar, se limpia la pila de navegación de vuelta al login (`Navigator.popUntil((route) => route.isFirst)`).
**Flujo alterno**: código inválido/expirado, o contraseñas que no coinciden → error inline en la pantalla correspondiente, sin avanzar.
**Postcondición**: contraseña actualizada en el backend; el usuario debe iniciar sesión de nuevo (el flujo no autentica automáticamente).

Wiring: `AuthInjection.forgotPassword()` (un único `ForgotPasswordController` para los 3 pasos).
