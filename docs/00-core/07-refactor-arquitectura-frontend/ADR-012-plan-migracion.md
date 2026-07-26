# Plan de Migración — ADR-012 (Fase 1)

> Entregable de Fase 1 de [ADR-012](./ADR-012-refactor-arquitectura-frontend.md): lista de pantallas afectadas, widgets reutilizables, componentes candidatos a `shared/`, plan por feature y riesgos. Basado en inventario real del código (no solo nombres — se leyó el contenido de cada archivo grande y de cada widget candidato a duplicado).

## 1. Lista de pantallas afectadas

> **Actualización 2026-07-26:** `admin_dashboard_page.dart` y `member_dashboard_page.dart` se confirmaron como no vigentes (mocks descartados, sin referencias en el resto del código) y se **eliminaron** del proyecto. Quedan 12 pantallas activas.

12 pantallas en total. Umbral de división obligatoria: **> 300 líneas** (5 de 12, ~42%, lo superan hoy).

| Archivo | Líneas | Feature | ¿Requiere división (Fase 4)? | Notas |
|---|---|---|---|---|
| `tenant/presentation/pages/tenant_page.dart` | 829 | tenant | Sí | 13 clases privadas inline; contiene `_RoleChip`/`_StatusChip` duplicados (ver §3) |
| `tenant/presentation/pages/create_tenant_page.dart` | 820 | tenant | Sí | 12 clases privadas inline, incluye `_BackendErrorCard`/`_FieldLabel`/`_GridPainter` duplicados |
| `auth/presentation/pages/register_page.dart` | 791 | auth | Sí | 13 clases privadas inline, 7 patrones de validación, `_BackendErrorCard`/`_FieldLabel`/`_GridPatternPainter` duplicados |
| `tenant/presentation/pages/join_tenant_page.dart` | 753 | tenant | Sí | Contiene **2 diálogos completos inline** (`_SuccessDialog` con animación, `_ErrorDialog`) que deben extraerse a `dialogs/` |
| `user/presentation/pages/password/change_password_page.dart` | 542 | user | Sí | Widgets reutilizables (`PasswordField`, `PrimaryButton`) declarados públicos pero viven en el archivo de la page, no en `widgets/` |
| `user/presentation/widgets/profile/edit_profile_bottom_sheet.dart` | 416 | user | Sí (aunque ya vive en `widgets/`) | 12 `TextEditingController` + validación + llamada a controller en un solo archivo → candidato a extraer a `forms/` |
| `auth/presentation/pages/login_page.dart` | 345 | auth | Sí (división ligera) | El más simple de los 7; buen candidato para ser el primero migrado end-to-end (piloto de Fase 2-5) |
| `dashboard/presentation/pages/personal/personal_dashboard_page.dart` | 298 | dashboard | No (límite) | Vigilar — está a 2 líneas del umbral |
| `auth/presentation/pages/verification_code_page.dart` | 249 | auth | No | — |
| `shell/presentation/pages/main_layout.dart` | 241 | shell | No (pero sí reorganización de navegación, ver [03-arquitectura-navegacion.md](./03-arquitectura-navegacion.md)) | — |
| `auth/presentation/pages/reset_password_page.dart` | 241 | auth | No | — |
| `user/presentation/pages/profile/profile_page.dart` | 211 | user | No | — |
| `auth/presentation/pages/forgot_password_page.dart` | 209 | auth | No | — |

## 2. Lista de widgets reutilizables (inventario actual, por feature)

| Feature | Widgets en `presentation/widgets/` |
|---|---|
| `auth` (`widgets/login/`) | `backend_error_card.dart`, `create_account_card.dart`, `left_identity_panel.dart` (incluye `IndicatorInfoBlock`, `GridPatternPainter`), `login_form_header.dart`, `login_utils.dart`, `social_logins_grid.dart` |
| `dashboard` (`widgets/`, mayormente `personal/`) | `no_active_organization_card.dart`, `account_state_card.dart`, `first_steps_checklist.dart`, `geometric_pattern_painter.dart`, `header_user_block.dart`, `hero_state_card.dart`, `interactive_action_button.dart`, `main_dashboard_feed.dart`, `metrics_summary_block.dart`, `premium_gradient_header.dart`, `quick_actions_grid.dart`, `quick_metrics_bar.dart`, `recent_activity_timeline.dart`, `recent_organizations_list.dart`, `security_management_card.dart`, `side_control_panel.dart`, `smart_recommendations_section.dart`, `upcoming_modules_section.dart` |
| `shell` (`widgets/`) | `app_back_button.dart`, `header_clipper.dart` |
| `user` (`widgets/profile/`) | `avatar_progress_painter.dart`, `base_container_card.dart`, `contact_info_card.dart`, `data_tile.dart`, `edit_profile_bottom_sheet.dart`, `logout_card.dart`, `organizations_section.dart`, `personal_info_card.dart`, `preferences_card.dart`, `profile_avatar.dart`, `profile_completion_card.dart`, `profile_header_clipper.dart`, `profile_header.dart`, `profile_stats.dart`, `recent_activity_card.dart`, `role_Chip.dart`, `security_card.dart`, `status_chip.dart` |

Además, **7-13 widgets privados por pantalla grande** (headers, decoraciones de fondo, form fields, success/error views) viven hoy inline dentro de las pages listadas en §1, sin archivo propio — son el grueso del trabajo de la Fase 4.

## 3. Lista de componentes que pasan a `shared/` (duplicación confirmada)

Estos son los únicos candidatos **confirmados** (2+ implementaciones reales del mismo concepto, leídas y comparadas — no solo nombres parecidos). Todo lo demás se queda en la feature hasta tener un segundo consumidor real (criterio de §3 de [02-arquitectura-objetivo.md](./02-arquitectura-objetivo.md)).

| Componente destino en `shared/` | Implementaciones actuales a unificar | Evidencia de duplicación |
|---|---|---|
| `shared/widgets/RoleChip` | `user/widgets/profile/role_Chip.dart` (`RoleChip`, pública) + `tenant/tenant_page.dart:574` (`_RoleChip`, privada) | Misma estructura `Wrap`+`Container`, misma firma `List<String> roles`; la de tenant tiene un switch de colores ya marcado como código muerto cosmético en ADR-011 |
| `shared/widgets/StatusChip` | `user/widgets/profile/status_chip.dart` (`StatusChip`) + `tenant/tenant_page.dart:614` (`_StatusChip`, con dot indicator + 3 estados) | La versión de tenant es superset estricto — al unificar, esa es la que gana |
| `shared/widgets/BackendErrorCard` | `auth/widgets/login/backend_error_card.dart` + `register_page.dart:598` (`_BackendErrorCard`) + `create_tenant_page.dart:715` (`_BackendErrorCard`) | **Las 3 son código casi idéntico carácter por carácter** — mismo `Container`/`BoxDecoration`/`IconButton`, solo cambia el texto del título |
| `shared/widgets/FieldLabel` | `register_page.dart:670` (`_FieldLabel`) + `create_tenant_page.dart:751` (`_FieldLabel`) | Clase idéntica definida dos veces de forma independiente |
| `shared/design_system` → painter de fondo (`GridPatternPainter`) | `dashboard/widgets/personal/geometric_pattern_painter.dart` + `auth/widgets/login/left_identity_panel.dart:129` (`GridPatternPainter`) + `register_page.dart:776` (`_GridPatternPainter`) + `create_tenant_page.dart:805` (`_GridPainter`) | 4 implementaciones distintas del mismo concepto visual — mayor duplicación encontrada en todo el inventario |
| `shared/widgets/BrandIdentityPanel` | `auth/widgets/login/left_identity_panel.dart` (`LeftIdentityPanel`) + `register_page.dart:463` (`_LeftRegisterIdentityPanel`) + `create_tenant_page.dart:534` (`_LeftIdentityWorkspacePanel`) | Mismo propósito (panel de marca en layout Desktop de 2 columnas), 3 implementaciones no compartidas |
| `shared/widgets/LoadingButton` (o `design_system/buttons/`) | `change_password_page.dart` (`PrimaryButton`) + `join_tenant_page.dart` (`_LoadingButton`) | Mismo concepto: botón primario con estado de carga/spinner |

**Nota de alcance:** unificar estos 7 componentes es trabajo de Fase 6, y depende de que la Fase 4 primero los extraiga de las pages a archivos propios dentro de cada feature. No se saltan pasos: primero se separan (Fase 4), después se comparan y unifican en `shared/` (Fase 6).

## 4. Plan de migración por Feature

| Feature | Estado actual | Foco de la migración |
|---|---|---|
| `auth` | 5 pages, 2 de ellas (>300 líneas) requieren división; widgets ya parcialmente organizados en `widgets/login/` | Candidato a **piloto** (`LoginScreen` es la pantalla grande más simple). Luego `RegisterScreen` (la más compleja del feature: validación de password, 13 widgets inline) |
| `user` | 2 pages + 18 widgets en `widgets/profile/` (ya relativamente bien organizado) | Extraer `edit_profile_bottom_sheet.dart` a `forms/`; separar `change_password_page.dart` en widgets propios ya identificados (`PasswordField`, `PasswordRequirementsList`, `PrimaryButton`) |
| `tenant` | 3 pages, las 3 por encima de 300 líneas (la feature con más deuda concentrada) | Mayor prioridad de Fase 4. `join_tenant_page.dart` necesita extracción de sus 2 diálogos inline con animación — la extracción más delicada de todo el inventario |
| `dashboard` | 1 page (`personal_dashboard_page.dart`, 298 líneas) — los mocks de admin/member se eliminaron por no vigentes (2026-07-26) | Sin deuda de tamaño pendiente; el módulo de dashboard admin/member se reconstruirá desde cero cuando el negocio defina el diseño vigente, directamente con la estructura objetivo de ADR-012 |
| `shell` | 1 page (`main_layout.dart`, 241 líneas, no requiere división) | Foco es navegación (ver [03-arquitectura-navegacion.md](./03-arquitectura-navegacion.md)), no tamaño de archivo: registrar rutas por feature en vez del switch centralizado, y resolver el tab 2 ("Usuarios") reservado sin pantalla |
| `core` | Hoy solo `routes/`, `errors/`, `presentation/styles/app_colors.dart` | Se expande a la estructura completa de §2 de [02-arquitectura-objetivo.md](./02-arquitectura-objetivo.md) (`networking/`, `storage/`, `design_system/`, etc.) — mayormente carpetas nuevas, no migración de código existente salvo mover `app_routes.dart`/`app_navigator.dart`/`api_exception.dart`/`app_colors.dart` a sus nuevas ubicaciones |
| `organization` / `financial` / `inventory` / futuros | No existen aún | Se crean directamente con la estructura objetivo desde el día 1 — ninguna migración, solo aplicar el patrón ya definido |

## 5. Riesgos detectados

| Riesgo | Detalle | Mitigación sugerida |
|---|---|---|
| **Uso inconsistente de `AppNavigator`** | De ~30 sitios que navegan, solo 2 (`app_back_button.dart`, `security_card.dart`) usan `AppNavigator`; el resto llama `Navigator` directo, incluyendo `main_layout.dart` mismo | La Fase 2 (renombrado `*Page`→`*Screen`) es el momento natural para tocar estos call sites de todas formas — aprovechar para unificar en `AppNavigator` al mismo tiempo, no como paso separado |
| **Rutas como strings libres fuera de `AppRoutes`** | `'/'` y `'/dashboard'` se usan como literales en `main_layout.dart` y `quick_actions_grid.dart`; `"/register"` literal en `create_account_card.dart:30`; `"/dashboard"` literal en `create_tenant_page.dart:126` | Corregir al registrar rutas por feature (Fase 2-3) — usar el compilador para detectar todos los literales al eliminar los strings sueltos |
| **Diálogos con estado y animación embebidos** | `join_tenant_page.dart` tiene `_SuccessDialog`/`_ErrorDialog` con su propio `State` y animaciones, mezclados con el flujo de unirse a organización | Extraer con cuidado en Fase 4 — es la extracción de mayor riesgo de regresión visual de todo el inventario, debe probarse manualmente en el flujo real (no solo compilar) |
| **`showDialog`/`showGeneralDialog` usan `useRootNavigator: true` por defecto** | Ya documentado en `arquitectura-frontend.md`; varias pages (`join_tenant_page.dart` entre ellas) capturan `Navigator.of(context)` antes de abrir el diálogo para poder hacer doble `pop` | Preservar este patrón explícitamente al migrar — es fácil perderlo al mover código a un archivo nuevo y olvidar la captura temprana del navigator |
| **Responsive hecho por duplicación, no por breakpoint compartido** | 9 usos de `LayoutBuilder`/`MediaQuery` en el código, cada uno con su propio umbral hardcodeado (login, register, create_tenant deciden Desktop/Mobile cada uno por su cuenta) | Al introducir `Breakpoints` en Fase 5, auditar que los 3 umbrales actuales sean consistentes entre sí antes de reemplazarlos — pueden no coincidir hoy y eso cambiaría el punto de corte visual existente |
| **Colores hardcodeados fuera de `AppColors`** | Valores como `0xFFFEF2F2`, `0xFF991B1B`, `0xFFDCFCE7` se repiten literalmente en los 3 `_BackendErrorCard` y en los chips duplicados, en vez de referenciar `AppColors` | Se resuelve como efecto colateral de unificar los componentes de §3 en Fase 6-7, no requiere trabajo separado |
| **Tab "Usuarios" del bottom nav reservado sin pantalla** | Índice 2 de `MainLayout._onItemTapped` no navega a nada | Aclarar con producto si esto se resuelve dentro de este ADR o queda fuera de alcance (parece más bien parte de un futuro módulo de gestión de usuarios) |
| **`flutter test` ya falla hoy** (no introducido por este ADR) | `test/widget_test.dart` es el template default, no corresponde a la app real (ver CLAUDE.md) | Fuera de alcance de ADR-012, pero si la Fase 8 (validación final) incluye "el proyecto compila sin regresiones", conviene arreglar este test *antes* de empezar, para tener una señal verde real de partida |

## 6. Orden recomendado de ejecución (Fases 2-8)

1. **Fase 2** (renombrado `Page`→`Screen`) sobre las 14 pantallas, aprovechando para unificar navegación en `AppNavigator` y eliminar rutas-string sueltas (mitiga 2 riesgos con un solo pase).
2. **Fase 3** (nueva estructura de carpetas) creada vacía, sin mover código todavía.
3. **Fase 4**, empezando por `auth/LoginScreen` como piloto (la pantalla grande más simple), después `tenant/*` (mayor concentración de deuda). El módulo dashboard admin/member se reconstruye desde cero con la estructura objetivo cuando el negocio defina su diseño vigente (los mocks anteriores fueron eliminados).
4. **Fase 5** (responsive) sobre las pantallas ya divididas en Fase 4, empezando por Login/Dashboard/Register/CreateTenant/JoinTenant como indica [04-estrategia-responsive.md](./04-estrategia-responsive.md).
5. **Fase 6** (shared) unificando los 7 componentes confirmados en §3.
6. **Fase 7** (design system) formalizando `AppColors` existente + agregando typography/spacing/radius/breakpoints que hoy no existen.
7. **Fase 8** validación final, incluyendo dejar `flutter test` en verde real antes de cerrar el ADR.
