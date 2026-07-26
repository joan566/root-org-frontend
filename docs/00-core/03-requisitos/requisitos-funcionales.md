# Requisitos Funcionales

Capacidades actualmente implementadas y en funcionamiento en el frontend, organizadas por módulo. Cada una enlaza al caso de uso correspondiente cuando existe documentación detallada.

## Autenticación (`features/auth`)

- **RF-01 — Registro de cuenta**: un usuario nuevo crea una cuenta con nombre, teléfono, correo y contraseña (`POST /auth/users/create`). Al finalizar, se le redirige a iniciar sesión.
- **RF-02 — Inicio de sesión**: un usuario se autentica con correo y contraseña (`POST /auth/login`) y obtiene un token JWT + su sesión (usuario, organizaciones, `hasTenant`).
- **RF-03 — Recuperación de contraseña**: flujo de 3 pasos — solicitar código por correo, verificar el código (obtiene un `resetToken`), y establecer una nueva contraseña usando ese token.
- **RF-04 — Reenvío de código de verificación**: desde la pantalla de verificación, reenviar el código si no llegó, con feedback de éxito/error.

Ver [casos de uso — autenticación](../04-casos-de-uso/authentication/casos-de-uso.md).

## Organizaciones / Tenants (`features/tenant`)

- **RF-05 — Crear organización**: un usuario autenticado crea una organización nueva (nombre + descripción) y queda como su propietario (`roles: ["Admin"]` asignado automáticamente por el backend). Recibe un código de invitación único para compartir.
- **RF-06 — Unirse a una organización por código**: un usuario ingresa el código de invitación de una organización y queda vinculado a ella con el rol base `Member`. El formulario no permite elegir un rol — el backend lo asigna siempre.
- **RF-07 — Listar organizaciones propias**: ver todas las organizaciones a las que el usuario pertenece, con su nombre, código, roles y estado.

Ver [casos de uso — tenant](../04-casos-de-uso/tenant/casos-de-uso.md).

## Perfil de usuario (`features/user`)

- **RF-08 — Ver perfil**: consultar los datos personales del usuario autenticado y sus organizaciones vinculadas.
- **RF-09 — Editar perfil**: actualizar nombre, apellido, documento, teléfono, fecha de nacimiento y género.
- **RF-10 — Cambiar contraseña**: cambiar la contraseña desde la sesión activa, validando requisitos de seguridad (longitud, mayúscula, minúscula, número, carácter especial) antes de enviar.
- **RF-11 — Cerrar sesión**: terminar la sesión activa y volver a la pantalla de login.

Ver [casos de uso — user](../04-casos-de-uso/user/casos-de-uso.md).

## Panel principal (`features/dashboard`)

- **RF-12 — Panel principal personal**: al iniciar sesión, ver un resumen del estado de la cuenta — organizaciones vinculadas, rol activo, checklist de primeros pasos (perfil completo, correo verificado, primera organización creada), accesos rápidos a crear/unirse a una organización, y actividad reciente.
- **RF-13 — Estado "sin organización"**: si el usuario no pertenece a ninguna organización, el panel muestra una vista dedicada con las acciones de crear/unirse, en vez del panel completo.

## Navegación (`features/shell`)

- **RF-14 — Navegación autenticada**: una vez logueado, el usuario navega entre Inicio, Organizaciones y Perfil mediante una barra de navegación inferior, con un botón flotante de acceso directo a "Crear organización". El espacio "Usuarios" existe en la barra pero no tiene pantalla asignada todavía.

## Fuera de alcance actual (mockups sin conectar)

`AdminDashboardPage` y `MemberDashboardPage` (`features/dashboard/presentation/pages/`) son **vistas estáticas con datos de ejemplo hardcodeados** (saldos, aportes, préstamos, gráficas) — no están enrutadas desde ningún lugar de la app, no llaman a ningún controller/API, y no reaccionan a la sesión real. Son una previsualización visual del futuro módulo de Gestión Financiera (Sprint 4, ver [ADR-011](../06-api-integration/ADR-011-sistema-permisos.md)), no una funcionalidad activa.
