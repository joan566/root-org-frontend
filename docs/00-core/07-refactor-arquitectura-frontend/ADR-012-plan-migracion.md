# Plan de Migración — ADR-012 (Fase 1)

> Entregable de Fase 1 de [ADR-012](./ADR-012-refactor-arquitectura-frontend.md): lista de pantallas afectadas, widgets reutilizables, componentes candidatos a `shared/`, plan por feature y riesgos. Basado en inventario real del código (no solo nombres — se leyó el contenido de cada archivo grande y de cada widget candidato a duplicado).

## 1. Lista de pantallas afectadas

> **Actualización 2026-07-26:** `admin_dashboard_page.dart` y `member_dashboard_page.dart` se confirmaron como no vigentes (mocks descartados, sin referencias en el resto del código) y se **eliminaron** del proyecto. Quedan 12 pantallas activas.
>
> **Actualización 2026-07-26 (Fase 4 ejecutada):** las 6 filas marcadas ✅ abajo ya se dividieron — sus clases privadas/widgets inline se extrajeron a `widgets/`/`dialogs/`/`bottom_sheets/` propios de cada pantalla. Detalle de cada extracción en los mensajes de commit correspondientes. `login_screen.dart` (345 líneas) se evaluó y **no requirió división**: ya estaba compuesta casi enteramente de widgets extraídos previamente (`LoginFormHeader`, `LeftIdentityPanel`, etc.), sin clases privadas adicionales que mover.

12 pantallas en total. Umbral de división obligatoria: **> 300 líneas**.

| Archivo | Líneas (antes → después) | Feature | Fase 4 | Notas |
|---|---|---|---|---|
| `tenant/presentation/tenant_list/tenant_screen.dart` | 829 → 161 | tenant | ✅ Dividida | 11 clases privadas extraídas a `widgets/`; el modal de "crear o unirse" se extrajo a `bottom_sheets/create_or_join_bottom_sheet.dart` |
| `tenant/presentation/create_tenant/create_tenant_screen.dart` | 820 → 342 | tenant | ✅ Dividida | 10 clases privadas extraídas a `widgets/` |
| `auth/presentation/register/register_screen.dart` | 791 → 374 | auth | ✅ Dividida | 10 clases privadas extraídas a `widgets/`; `FieldLabel`/`MobileMiniBrandHeader` unificados con el compartido de `auth/widgets/login_utils.dart` (eran idénticos byte a byte) |
| `tenant/presentation/join_tenant/join_tenant_screen.dart` | 753 → 248 | tenant | ✅ Dividida | 6 widgets a `widgets/`; **los 2 diálogos animados** (`SuccessDialog`, `ErrorDialog`) extraídos a `dialogs/` preservando la asimetría de animación original — la extracción de mayor riesgo del plan, verificada con `flutter analyze` sin errores |
| `user/presentation/change_password/change_password_screen.dart` | 542 → 278 | user | ✅ Dividida | Las 5 clases públicas (`PasswordField`, `PrimaryButton`, etc.) ya estaban bien separadas, solo se movieron a `widgets/` |
| `user/presentation/profile/bottom_sheets/edit_profile_bottom_sheet.dart` | 416 → 369 | user | ✅ Parcial | Diálogo de error extraído a `dialogs/`; el formulario de 5 campos se mantiene como un único widget cohesivo (extraerlo a `forms/` no reduciría complejidad real sin más contexto de negocio) |
| `auth/presentation/login/login_screen.dart` | 345 | auth | No requerida | Ya compuesta de widgets extraídos previamente; sin clases privadas adicionales |
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

> **Actualización 2026-07-26 (Fase 6 ejecutada):** de los 7 candidatos, al leer el contenido completo de cada uno **solo 2 resultaron ser duplicación pura** (misma estructura, solo difieren en 1 valor primitivo) y se unificaron en `shared/widgets/`:
> - **`BackendErrorCard`** (3 variantes → 1, parametrizada por `title` y `borderOpacity`, default preserva el comportamiento de auth).
> - **`FieldLabel`** (2 variantes → 1, parametrizada por `fontWeight`, default preserva el de auth).
>
> Los otros **5 candidatos se reconsideraron y NO se unificaron**, porque al leer el código completo (no solo el nombre) resultaron ser divergencias reales de diseño, no duplicación accidental — forzarlos a un solo componente habría necesitado tantos parámetros para cubrir cada diferencia que la abstracción no habría reducido complejidad real, solo la habría movido de sitio:
> - **`RoleChip` vs `TenantRoleChip`**: el de `user` pinta *todos* los roles del mismo color; el de `tenant` tiene un switch de color por nombre de rol (`administrador`/`propietario`/`consultor`, ya marcado como código muerto cosmético en ADR-011 porque no coincide con los valores reales del backend). Son dos decisiones de color distintas, no la misma lógica duplicada.
> - **`StatusChip` vs `TenantStatusChip`**: el de `tenant` distingue 3 estados con color+punto indicador; el de `user` solo distingue 2 (activo/no-activo) sin punto. Unificarlos habría cambiado el color mostrado en `ProfileScreen` para el estado "suspendido" (hoy ámbar, pasaría a rojo) — un cambio de comportamiento visible, no una refactorización neutra.
> - **Painter de fondo geométrico** (4 implementaciones): cada uno tiene su propio color/opacidad/espaciado de grid y vive en un contexto visual distinto (dashboard vs. 3 paneles de marca). No son la misma decoración reutilizada, son 4 decoraciones bespoke que solo comparten la *técnica* (`CustomPainter` con líneas).
> - **Panel de identidad lateral** (`LeftIdentityPanel`/`LeftRegisterIdentityPanel`/`LeftIdentityWorkspacePanel`): además de tener copy distinto (esperado, parametrizable), divergen en padding (54/54/48), presencia y opacidad del círculo decorativo (0.15/0.12/ausente), y sobre todo en **qué sección va al final** (3 stats / 2 mini-cards de feature / lista numerada de pasos) — tres tipos de widget distintos, no una plantilla con texto intercambiable.
> - **`LoadingButton` vs `PrimaryButton`**: distinto widget base (`FilledButton` vs `ElevatedButton`), distinta altura (56 vs 54), distinto color de fondo deshabilitado, y `LoadingButton` tiene una regla de negocio adicional (`isValid`) que `PrimaryButton` no tiene. Son dos botones con apariencia y reglas de habilitación distintas, no el mismo botón con texto distinto.
>
> Esta re-evaluación es un resultado válido de Fase 6, no un trabajo pendiente: el inventario de Fase 1 comparó nombres y estructura superficial; comparar el contenido completo reveló que la mayoría de las "duplicaciones" encontradas eran en realidad decisiones de diseño distintas por contexto.

> **Actualización 2026-07-26 (Fase 4 ejecutada):** al extraer `register_screen.dart`, `create_tenant_screen.dart` y `tenant_screen.dart` se encontraron **2 casos adicionales** de duplicación no listados arriba (el inventario de Fase 1 solo comparó nombres/archivos ya existentes, no el contenido completo de las pantallas grandes, que todavía no se había leído en detalle):
> - `FieldLabel` y `MobileMiniBrandHeader` de `register_screen.dart` eran **copias byte-a-byte idénticas** de las ya compartidas en `auth/presentation/widgets/login_utils.dart` → se eliminó la copia y se apunta directamente al compartido (cero cambio de comportamiento, menos código).
> - `FormDivider`, `BackendErrorCard`/`_BackendErrorCard`, `AbstractBackgroundDecoration`, `FutureSocialLoginsGrid`/`_LeftIdentityWorkspacePanel`/`_LeftRegisterIdentityPanel`, `TenantRoleChip`/`TenantStatusChip` **se parecen pero difieren** en texto, fontWeight, opacidad o proveedores listados entre `register_screen.dart`, `create_tenant_screen.dart` y los compartidos de `auth`/`user` → se mantuvieron como archivos propios de cada pantalla (`RegisterFormDivider`, `WorkspaceBackendErrorCard`, etc.) en vez de forzar una unificación que habría alterado contenido visual sin aprobación explícita. Siguen siendo candidatos válidos para Fase 6, pero esa fase deberá decidir explícitamente cuál texto/valor "gana" en cada caso (mismo patrón que las decisiones de ADR-011).

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

1. **Fase 2** ✅ ejecutada — renombrado `Page`→`Screen` sobre las 12 pantallas activas.
2. **Fase 3** ✅ ejecutada — `lib/core/`, `lib/shared/` y estructura `presentation/<screen>/` creadas.
3. **Fase 4** ✅ ejecutada (2026-07-26) para las 6 pantallas que la requerían (ver tabla actualizada en §1). `LoginScreen` se evaluó como piloto y no necesitó división. El módulo dashboard admin/member se reconstruye desde cero con la estructura objetivo cuando el negocio defina su diseño vigente (los mocks anteriores fueron eliminados).
4. **Fase 5** ✅ ejecutada (2026-07-26) — `Breakpoints` creado en `core/design_system/breakpoints/`; `LoginScreen`, `RegisterScreen` y `CreateTenantScreen` (las únicas 3 con composición Desktop/Mobile genuinamente distinta) divididas en `*MobileView`/`*DesktopView`, cada una preservando su umbral histórico propio (950/950/1050) — ver detalle en [04-estrategia-responsive.md](./04-estrategia-responsive.md). El resto de pantallas queda en vista única (estado transitorio válido) hasta que haya necesidad real de un layout Desktop distinto.
5. **Fase 6** ✅ ejecutada (2026-07-26) — de los 7 candidatos, 2 eran duplicación real y se unificaron en `shared/widgets/` (`BackendErrorCard`, `FieldLabel`); los otros 5 se reconsideraron tras leer el contenido completo y resultaron ser divergencias reales de diseño, no duplicación — ver detalle en §3.
6. **Fase 7** ✅ ejecutada (2026-07-26) — se crearon los tokens que faltaban en `core/design_system/`: `typography/app_typography.dart` (`AppTypography`, escala estilo Material 3 formalizada a partir de las combinaciones fontSize/fontWeight/color más repetidas en el código real — ver conteos en el commit), `spacing/app_spacing.dart` (`AppSpacing`), `radius/app_radius.dart` (`AppRadius`). `colors/` (`AppColors`) y `breakpoints/` (`Breakpoints`) ya existían de antes (Fase 3 y 5). **Elevación/sombras no se movieron** a una carpeta propia: ya viven como métodos de `AppColors` (`premiumShadow()`/`subtleShadow()`/`floatingShadow()`) y separarlas solo movería código sin valor real. `shared/widgets/field_label.dart` se actualizó para consumir `AppTypography.labelMedium` como demostración concreta de uso. **Los tokens son el default recomendado para código nuevo — no se retroactivó ningún widget existente** (cientos de usos de `fontSize`/`SizedBox`/`BorderRadius.circular` literales en toda la app); hacerlo sería una migración mecánica de alto volumen y bajo riesgo pero sin urgencia real, fuera del alcance de esta fase. `design_system/{buttons,cards,dialogs,inputs,tables,navigation}/` quedan vacíos: construir esos componentes sin un consumidor concreto sería abstracción prematura.
7. **Fase 8** validación final, incluyendo dejar `flutter test` en verde real antes de cerrar el ADR.
