# Casos de Uso — Usuario / Perfil

## CU-07: Ver perfil

**Actor**: usuario autenticado.
**Precondición**: sesión activa.
**Flujo principal**:
1. El usuario navega a la pestaña "Perfil".
2. `ProfilePage` llama `GET /users/profile` (`GetUserController`) y actualiza `AuthProvider` con `auth.updateUser(result.user)` para mantener la sesión sincronizada con el backend.
3. Se muestran: datos personales, información de contacto, organizaciones vinculadas (con sus roles), estado de completitud del perfil, seguridad y preferencias.
**Postcondición**: ninguna (solo lectura, aunque refresca la sesión en memoria).

Pantalla: `ProfilePage`. Wiring: `UsersInjection.getUserController()`.

## CU-08: Editar perfil

**Actor**: usuario autenticado.
**Precondición**: sesión activa.
**Flujo principal**:
1. Desde `ProfilePage`, el usuario abre la hoja inferior de edición (`EditProfileBottomSheet`).
2. Modifica nombre, apellido, documento, teléfono, fecha de nacimiento y/o género.
3. `POST /users/update-profile` → si es exitoso, `AuthProvider.updateUser(response.user)` actualiza la sesión y notifica a los listeners; la hoja se cierra devolviendo el usuario actualizado.
**Flujo alterno**: error del backend → diálogo de error dedicado (`AlertDialog`) con botón "Entendido".
**Postcondición**: datos de perfil actualizados en backend y en la sesión local.

Wiring: `UsersInjection.updateProfileController()`.

## CU-09: Cambiar contraseña

**Actor**: usuario autenticado.
**Precondición**: sesión activa; conoce su contraseña actual.
**Flujo principal**:
1. Desde el perfil (tarjeta de seguridad) el usuario abre `ChangePasswordPage`.
2. Ingresa contraseña actual, nueva contraseña y confirmación. La UI valida en vivo 5 requisitos de seguridad (longitud ≥ 8, mayúscula, minúscula, número, carácter especial) antes de permitir el envío.
3. `POST /auth/users/change-password` → mensaje de éxito inline y limpieza de los campos.
**Flujo alterno**: contraseña actual incorrecta, o nueva contraseña no cumple requisitos → mensaje de error inline; el usuario permanece en la pantalla.
**Postcondición**: contraseña actualizada; la sesión actual sigue activa (no se fuerza un nuevo login).

Pantalla: `ChangePasswordPage`. Wiring: `UsersInjection.changePasswordController()`.

## CU-10: Cerrar sesión

**Actor**: usuario autenticado.
**Precondición**: sesión activa.
**Flujo principal**:
1. Desde el perfil, el usuario selecciona "Cerrar sesión".
2. `AuthProvider.logout()` limpia la sesión en memoria y notifica a los listeners.
3. `MainApp` reacciona automáticamente (mismo mecanismo que CU-02) y muestra `LoginPage`.
**Postcondición**: sesión terminada; el token JWT no se invalida explícitamente en el backend, solo se descarta del cliente.

## Nota

"Solicitar eliminación de cuenta" existe como opción visual en la tarjeta de cierre de sesión (`LogoutCard`) pero **no está implementada** — su `onTap` no ejecuta ninguna acción; es un placeholder para un flujo legal futuro (GDPR/ARCO).
