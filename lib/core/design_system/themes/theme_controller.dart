import 'package:flutter/material.dart';

import '../../storage/local_storage.dart';
import '../../storage/storage_keys.dart';

final class ThemeController extends ChangeNotifier {
  ThemeController._({
    required LocalStorage localStorage,
    required ThemeMode themeMode,
  }) : _localStorage = localStorage,
       _themeMode = themeMode;

  final LocalStorage _localStorage;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeController> load(LocalStorage localStorage) async {
    final storedMode = localStorage.getString(StorageKeys.themeMode);
    final themeMode = ThemeMode.values
        .where((mode) => mode.name == storedMode)
        .firstOrNull;

    return ThemeController._(
      localStorage: localStorage,
      themeMode: themeMode ?? ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    await _localStorage.setString(StorageKeys.themeMode, mode.name);
    _themeMode = mode;
    notifyListeners();
  }
}
