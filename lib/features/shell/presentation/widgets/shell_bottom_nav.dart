import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'shell_section.dart';

/// Bottom navigation adaptativa del shell en Mobile (ver
/// docs/frontend-navigation-redesign.md §2). Reemplaza el bottom nav fijo
/// de 4 posiciones + FAB de `MainLayout` por las 5 secciones principales,
/// sin acoplar una acción flotante a "crear organización" (deuda ya
/// señalada en ADR-012, docs/00-core/07-refactor-arquitectura-frontend/
/// 03-arquitectura-navegacion.md).
class ShellBottomNav extends StatelessWidget {
  final List<ShellSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ShellBottomNav({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: colors.premiumShadow(),
          ),
          child: Row(
            children: [
              for (int i = 0; i < sections.length; i++)
                _BottomNavItem(
                  section: sections[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ítem del bottom nav: solo ícono. Con 5 secciones (dos de ellas con
/// etiquetas largas, "Organización"/"Administración"), cualquier variante
/// con texto —incluso solo en el ítem activo— se queda sin espacio en
/// anchos móviles típicos (~390px / 5 = ~78px por ítem). El label sigue
/// disponible como `Tooltip` (accesible al mantener presionado / hover).
class _BottomNavItem extends StatelessWidget {
  final ShellSection section;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({required this.section, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Expanded(
      child: Tooltip(
        message: section.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? colors.primary.withOpacity(.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(section.icon, size: 22, color: selected ? colors.primary : colors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
