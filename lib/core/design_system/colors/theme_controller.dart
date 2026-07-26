import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado global del modo de tema (claro/oscuro/sistema), con persistencia
/// en disco vía shared_preferences.
///
/// Solo guarda la preferencia del usuario (`mode`). La resolucion a
/// AppPalette.light/dark segun el brillo real (incluyendo el del sistema
/// operativo cuando `mode == ThemeMode.system`) vive en `AppColors.of(context)`,
/// para que reaccione tanto a cambios de este controller como a cambios de
/// brillo del SO en caliente.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeController() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null) return;

    for (final candidate in ThemeMode.values) {
      if (candidate.name == stored && candidate != _mode) {
        _mode = candidate;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
