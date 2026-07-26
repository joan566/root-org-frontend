# Plan de Implementación: Recuperación de Contraseña

Este plan detalla la integración del flujo de recuperación de contraseña, incluyendo las pantallas de solicitud de código, verificación y restablecimiento de contraseña.

## User Review Required

> [!IMPORTANT]
> Es necesario confirmar los endpoints exactos del backend para:
> 1. Solicitar el código de recuperación (`forgot-password`).
> 2. Verificar el código (`verify-code`).
> 3. Cambiar la contraseña (`reset-password`).
>
> Asumiré temporalmente que siguen el patrón de `auth/forgot-password`, `auth/verify-code` y `auth/reset-password`.

## Proposed Changes

### 1. Capa de Datos (Data Layer)

#### [MODIFY] [auth_api.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/data/datasources/auth_api.dart)
- Agregar métodos `forgotPassword(email)`, `verifyCode(email, code)` y `resetPassword(email, code, newPassword, confirmPassword)`.
- El método `resetPassword` enviará el payload: `{"email": ..., "resetCode": ..., "newPassword": ..., "confirmPassword": ...}`.

#### [MODIFY] [auth_repository_adapter.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/data/repositories/auth_repository_adapter.dart)
- Implementar los nuevos métodos del puerto.

### 2. Capa de Dominio (Domain Layer)

#### [MODIFY] [auth_respository_port.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/domain/repositories/auth_respository_port.dart)
- Definir los contratos para el flujo de recuperación.

#### [NEW] `forgot_password_use_case.dart`
#### [NEW] `verify_code_use_case.dart`
#### [NEW] `reset_password_use_case.dart`
- Casos de uso individuales para cada paso del proceso.

### 3. Capa de Presentación (Presentation Layer)

#### [NEW] `forgot_password_controller.dart`
- Controlador que gestionará el estado y las llamadas a los casos de uso para todo el flujo.

#### [NEW] [forgot_password_page.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/pages/forgot_password_page.dart)
- Pantalla para ingresar el correo electrónico.

#### [NEW] [verification_code_page.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/pages/verification_code_page.dart)
- Pantalla para ingresar el código de 4 o 6 dígitos.

#### [NEW] [reset_password_page.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/pages/reset_password_page.dart)
- Pantalla para establecer la nueva contraseña.

#### [MODIFY] [login_page.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/pages/login_page.dart)
- Conectar el botón "¿Olvidaste tu contraseña?" para navegar a `ForgotPasswordPage`.

#### [MODIFY] [auth_injection.dart](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/lib/features/auth/presentation/controllers/auth_injection.dart)
- Configurar la inyección para el nuevo controlador.

---

## Verification Plan

### Manual Verification
- Navegar desde Login a Forgot Password.
- Simular el envío de correo y verificar la navegación a Verification Code.
- Verificar que el ingreso del código lleve a Reset Password.
- Confirmar que el flujo finalice regresando al Login o iniciando sesión automáticamente.

### Automated Tests
- Se podrían agregar unit tests para los nuevos UseCases y el Controller si se requiere mayor robustez.
