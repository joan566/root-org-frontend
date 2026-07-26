# Requisitos No Funcionales

## Arquitectura

- **RNF-01 — Clean Architecture por módulo**: cada feature de negocio separa `data`/`domain`/`presentation` para que la lógica de negocio (entidades, casos de uso) no dependa de Flutter ni de la forma exacta del JSON del backend. Ver [arquitectura-frontend.md](../02-arquitectura/arquitectura-frontend.md).
- **RNF-02 — Escalabilidad modular**: agregar un módulo nuevo (ej. el futuro módulo financiero) no debe requerir tocar la estructura de los módulos existentes — cada feature es autocontenida bajo `lib/features/<nombre>/`.

## Plataformas soportadas

- **RNF-03**: la app es Flutter multiplataforma — hay proyectos nativos generados para Android, iOS, Web, Linux, Windows y macOS (`android/`, `ios/`, `web/`, `linux/`, `windows/`, `macos/`). El desarrollo y las pruebas de este ciclo se hicieron sobre el flujo web/desktop; no se ha validado específicamente el empaquetado móvil.

## Seguridad

- **RNF-04 — Autenticación por JWT**: toda operación autenticada envía `Authorization: Bearer <token>`. El token se obtiene en login/registro y vive únicamente en memoria (`AuthProvider`) — no hay almacenamiento persistente (`shared_preferences`, `secure_storage`) todavía, por lo que la sesión no sobrevive a un reinicio de la app.
- **RNF-05 — Autorización centralizada en backend**: el frontend no decide qué acciones críticas mostrar/ocultar en base al nombre de un rol (`roles`); esa validación es responsabilidad exclusiva del backend. Ver [ADR-011](../06-api-integration/ADR-011-sistema-permisos.md).
- **RNF-06 — Manejo de errores HTTP tipado**: los datasources (`*Api`) lanzan `ApiException` con `statusCode`/`errorCode`/`message` en vez de excepciones genéricas, dejando preparado el manejo diferenciado de códigos como `403 FORBIDDEN_ERROR` sin necesidad de tocar cada pantalla.

## Consumo de API

- **RNF-07**: no hay configuración de entorno (`.env`, flavors) para la URL base del backend — está hardcodeada en cada `*Api` (`http://192.168.0.104:8080`). Cambiar de entorno (dev/staging/prod) requiere editar código.
- **RNF-08**: no hay reintentos automáticos, timeouts configurados explícitamente, ni caché de respuestas — cada request es un `http.post`/`http.get` directo.

## Calidad de código

- **RNF-09**: `flutter analyze` (con `flutter_lints`) debe pasar sin errores (warnings/infos preexistentes de estilo son deuda conocida, no bloqueante).
- **RNF-10**: el único archivo de test (`test/widget_test.dart`) es la plantilla por defecto de Flutter (contador) y no refleja la app real — actualmente falla si se ejecuta. No hay cobertura de tests automatizados sobre la lógica de negocio implementada.
