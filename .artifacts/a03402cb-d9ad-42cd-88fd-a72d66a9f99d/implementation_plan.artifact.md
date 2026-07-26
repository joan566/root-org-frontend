# Plan de Documentación del Frontend (Estructura Espejo Backend)

Este plan tiene como objetivo establecer una documentación exhaustiva y estructurada que sea un reflejo de la documentación del backend, facilitando la consistencia y el entendimiento global de la plataforma SUMKEYA.

## User Review Required

> [!IMPORTANT]
> Se propone adoptar una estructura de carpetas `docs/` en la raíz del proyecto para organizar toda la documentación técnica y funcional, manteniendo una jerarquía similar a la del backend.

## Proposed Changes

### 1. Estructura de Directorios `docs/`

Se creará la siguiente jerarquía para organizar la documentación:

- `docs/00-core/`: Documentación fundamental del frontend.
    - `01-vision/`: Visión del producto desde la perspectiva de la interfaz.
    - `02-arquitectura/`: Detalles de Clean Architecture en Flutter, gestión de estado con Provider y sistema de rutas.
    - `03-requisitos/`: Requisitos funcionales y no funcionales del frontend.
    - `04-casos-de-uso/`: Documentación detallada de la lógica de cada Use Case.
    - `05-dominio/`: Definición de entidades y reglas de negocio del lado del cliente.
    - `06-api-integration/`: Contratos de integración con el backend.
- `docs/01-features/`: Documentación específica de cada módulo funcional (Dashboard, User, Auth, etc.).

### 2. Documentación de Casos de Uso (Core)

Se crearán archivos `.md` para cada caso de uso detectado en el código, siguiendo el formato del backend:
- `docs/00-core/04-casos-de-uso/authentication/`: `LoginUserUseCase.md`, `RegisterUserUseCase.md`, `ChangePasswordUseCase.md`.
- `docs/00-core/04-casos-de-uso/tenant/`: `JoinTenantUseCase.md`, `RegisterTenantWithOwnerUseCase.md`.
- `docs/00-core/04-casos-de-uso/user/`: `GetUserProfileUseCase.md`, `UpdateUserProfileUseCase.md`.

### 3. Arquitectura y Decisiones Técnicas

#### [NEW] `docs/00-core/02-arquitectura/arquitectura-clean.md`
- Explicación de cómo Flutter implementa las capas de Domain, Data y Presentation.
- Responsabilidades de los Mappers y Adaptadores.

#### [NEW] `docs/00-core/02-arquitectura/design-system.md`
- Documentación de los tokens de diseño y componentes base (Widgets globales).

### 4. Actualización del README.md

#### [MODIFY] [README.md](file:///home/joan-sebastian-vergara/Desktop/savings_api_frontend/README.md)
- Actualizar para incluir un índice dinámico que apunte a la nueva estructura de `docs/`.

## Verification Plan

### Manual Verification
- Verificar que la jerarquía de carpetas en `docs/` sea fácil de navegar.
- Asegurar que los documentos de los Casos de Uso reflejen fielmente la lógica implementada en el código Dart.
- Comprobar que los diagramas Mermaid (si se incluyen) se rendericen correctamente.
