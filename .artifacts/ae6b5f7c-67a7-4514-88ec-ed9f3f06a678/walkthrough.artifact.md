# Walkthrough: Flujo de Recuperación de Contraseña

Se ha implementado el flujo completo para que los usuarios puedan restablecer su contraseña de forma segura.

## Cambios Realizados

### Capa de Datos
- **[AuthApi](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/data/datasources/auth_api.dart):** Se añadieron los endpoints `forgot-password`, `verify-code` y `reset-password`.
- **[AuthRepositoryPort](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/domain/repositories/auth_respository_port.dart) & [AuthRepositoryAdapter](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/data/repositories/auth_repository_adapter.dart):** Se definieron e implementaron los contratos para estos nuevos servicios.

### Capa de Dominio
Se crearon tres nuevos casos de uso para separar las responsabilidades del proceso:
- `ForgotPasswordUseCase`
- `VerifyCodeUseCase`
- `ResetPasswordUseCase`

### Capa de Presentación
- **[ForgotPasswordController](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/controllers/forgot_password_controller.dart):** Centraliza la lógica de los tres pasos.
- **Inyección:** Se actualizó `AuthInjection` para proveer el nuevo controlador.
- **Nuevas Pantallas:**
    - `ForgotPasswordPage`: Solicita el email.
    - `VerificationCodePage`: Recibe el código (6 dígitos).
    - `ResetPasswordPage`: Permite establecer la nueva contraseña validando que coincidan.
- **Integración:** Se conectó el botón "¿Olvidaste tu contraseña?" en la `LoginPage`.

## Cómo Probar

1. Abre la aplicación y ve a la pantalla de **Login**.
2. Toca en **¿Olvidaste tu contraseña?**.
3. Ingresa tu correo electrónico y presiona **Enviar código**.
4. Serás redirigido a la pantalla de verificación. Ingresa el código enviado a tu correo.
5. Finalmente, ingresa y confirma tu nueva contraseña. Al terminar, serás redirigido al Login para iniciar sesión con tus nuevas credenciales.

> [!TIP]
> Las validaciones de campos (email requerido, código requerido, contraseñas coincidentes) ya están integradas en los formularios.
