import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/colors/theme_controller.dart';
import 'package:savings_api_frontend/shared/widgets/base_container_card.dart';

class PreferencesCard extends StatelessWidget {
  const PreferencesCard();

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Automático (sistema)';
    }
  }

  void _showThemeModeSelector(BuildContext context) {
    final themeController = context.read<ThemeController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context, listen: false).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final colors = AppColors.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                Text('Tema visual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.4)),
                const SizedBox(height: 4),
                Text('Elige cómo quieres ver la aplicación.', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                const SizedBox(height: 24),
                _buildThemeOption(sheetContext, colors, Icons.brightness_auto_rounded, ThemeMode.system, themeController),
                const SizedBox(height: 12),
                _buildThemeOption(sheetContext, colors, Icons.light_mode_rounded, ThemeMode.light, themeController),
                const SizedBox(height: 12),
                _buildThemeOption(sheetContext, colors, Icons.dark_mode_rounded, ThemeMode.dark, themeController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, AppPalette colors, IconData icon, ThemeMode mode, ThemeController controller) {
    final bool isSelected = controller.mode == mode;

    return InkWell(
      onTap: () {
        controller.setMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? colors.primary : colors.border, width: isSelected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(_themeModeLabel(mode), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeMode = context.watch<ThemeController>().mode;

    return BaseContainerCard(
      title: 'Preferencias del entorno',
      icon: Icons.tune_rounded,
      children: [
        _buildPreferenceRow(colors, 'Idioma de interfaz', 'Español (Latinoamérica)', Icons.language_rounded),
        Divider(color: colors.border, height: 1),
        _buildPreferenceRow(colors, 'Región y Zona Horaria', 'Bogotá, Colombia (GMT-5)', Icons.public_rounded),
        Divider(color: colors.border, height: 1),
        _buildPreferenceRow(
          colors,
          'Tema visual del sistema',
          _themeModeLabel(themeMode),
          Icons.dark_mode_outlined,
          onTap: () => _showThemeModeSelector(context),
        ),
      ],
    );
  }

  Widget _buildPreferenceRow(AppPalette colors, String title, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right_rounded, size: 18, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
