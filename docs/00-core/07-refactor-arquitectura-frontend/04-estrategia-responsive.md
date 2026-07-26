# Documento de Estrategia Responsive (ADR-012, Fase 1)

> Entregable de Fase 1 de [ADR-012](./ADR-012-refactor-arquitectura-frontend.md).

## 1. Estado actual

El proyecto es Flutter multiplataforma (Android, iOS, Web, Linux, Windows, macOS — targets ya presentes en el repo: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`), pero la capa de presentación fue construida asumiendo un único layout tipo Mobile (bottom nav fijo, FAB centrado, pantallas de ancho único). El inventario de usos de `MediaQuery`/`LayoutBuilder`/breakpoints existentes se documenta en [ADR-012-plan-migracion.md](./ADR-012-plan-migracion.md).

## 2. Principio rector

**No se construyen dos aplicaciones.** Una única fuente de lógica (`domain/`, `data/`, `state/`) alimenta dos representaciones visuales por pantalla. El patrón, ya fijado en el ADR:

```
LoginScreen
   ↓ decide
   ↓
LoginDesktopView   o   LoginMobileView
```

## 3. Dónde vive la decisión

La `*Screen` es la única responsable de decidir qué `View` renderizar. No se decide en `main.dart` ni globalmente para toda la app — cada pantalla decide de forma independiente, porque distintas pantallas pueden necesitar puntos de corte distintos (ej. un formulario simple puede seguir viéndose bien en Mobile hasta un ancho mayor que una tabla densa de datos financieros).

```dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthInjection.login(); // wiring compartido, sin cambios

    return Breakpoints.isDesktop(context)
        ? LoginDesktopView(controller: controller)
        : LoginMobileView(controller: controller);
  }
}
```

`Breakpoints` vive en `core/design_system/breakpoints/` — es la única fuente de verdad sobre qué ancho cuenta como Desktop/Tablet/Mobile, consumida tanto por las `Screen` (para decidir vista) como por `shared/layouts/` (para layouts compuestos, ej. paneles laterales condicionales).

## 4. Breakpoints propuestos (punto de partida, a validar en Fase 5)

| Categoría | Ancho | Uso típico |
|---|---|---|
| Mobile | `< 600` | Layout actual: bottom nav, una columna, navegación por pantalla completa |
| Tablet | `600–1024` | Tratado como Mobile ampliado salvo que una pantalla concreta justifique un layout intermedio |
| Desktop | `>= 1024` | Navegación lateral persistente, paneles side-by-side, tablas densas en vez de listas de cards |

Estos valores son un punto de partida razonable (siguen el criterio estándar de Material Design) — se confirman o ajustan durante la Fase 5, pantalla por pantalla, no se fijan como verdad absoluta en Fase 1.

## 5. Qué comparten `DesktopView` y `MobileView`

Ambas reciben exactamente el mismo `Controller`/estado de `state/` y consumen las mismas `Entity` del dominio. Lo único que cambia es composición visual: qué widgets se muestran, en qué layout (columna vs. grilla vs. paneles), y qué interacciones son primarias (ej. un modal en Mobile puede ser un panel lateral permanente en Desktop). Ninguna lógica de validación, HTTP, o navegación de negocio se duplica entre las dos vistas — si una vista necesita lógica que la otra no tiene, esa lógica sube a `state/`, no se escribe dos veces.

## 6. Relación con `shared/layouts/` y navegación

Un `DesktopView` puede optar por representar una transición que en Mobile es un `Navigator.push` (pantalla completa nueva) como un panel o sección visible dentro del mismo layout (ej. lista + detalle side-by-side). Esa decisión es local a la `DesktopView` de esa pantalla — no cambia el registro de rutas de `core/routing/` (ver [03-arquitectura-navegacion.md](./03-arquitectura-navegacion.md)), que sigue siendo la navegación canónica usada por Mobile y disponible para Desktop cuando decide no componer side-by-side.

## 7. Migración incremental (Fase 5)

No se exige que las 8 pantallas grandes identificadas en el inventario tengan `DesktopView` completo desde el primer día. El orden sugerido:

1. Pantallas ya divididas en Fase 4 (más fácil separar Mobile/Desktop cuando la lógica ya no está enredada con el layout).
2. Pantallas de alto tráfico / primera impresión (`LoginScreen`, `DashboardScreen`).
3. Pantallas de formularios complejos (`RegisterScreen`, `CreateTenantScreen`, `JoinTenantScreen`) — se benefician más de un layout Desktop de dos columnas.
4. Resto de pantallas, bajo demanda de negocio.

Hasta que una pantalla tenga su `DesktopView` implementado, su `Screen` puede devolver directamente el `MobileView` sin importar el ancho — es un estado transitorio válido, no un bloqueador para avanzar con otras fases.
