# Tareas: Recuperación de Contraseña

- [x] **Capa de Datos**
    - [x] Modificar `AuthApi` para incluir `forgotPassword`, `verifyCode` y `resetPassword`
    - [x] Modificar `AuthRepositoryPort` con los nuevos métodos
    - [x] Modificar `AuthRepositoryAdapter` para implementar los nuevos métodos
- [x] **Capa de Dominio**
    - [x] Crear `ForgotPasswordUseCase`
    - [x] Crear `VerifyCodeUseCase`
    - [x] Crear `ResetPasswordUseCase`
- [x] **Capa de Presentación**
    - [x] Crear `ForgotPasswordController`
    - [x] Configurar inyección en `AuthInjection`
    - [x] Implementar `ForgotPasswordPage`
    - [x] Implementar `VerificationCodePage`
    - [x] Implementar `ResetPasswordPage`
    - [x] Conectar `LoginPage` con el flujo de recuperación
- [ ] **Verificación**
    - [ ] Probar flujo completo manualmente
