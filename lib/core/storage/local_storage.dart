import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions/app_exception.dart';

final class LocalStorage {
  const LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  String? getString(String key) => _preferences.getString(key);

  bool? getBool(String key) => _preferences.getBool(key);

  int? getInt(String key) => _preferences.getInt(key);

  double? getDouble(String key) => _preferences.getDouble(key);

  List<String>? getStringList(String key) => _preferences.getStringList(key);

  Future<void> setString(String key, String value) async {
    if (!await _preferences.setString(key, value)) {
      throw const StorageException();
    }
  }

  Future<void> setBool(String key, bool value) async {
    if (!await _preferences.setBool(key, value)) {
      throw const StorageException();
    }
  }

  Future<void> setInt(String key, int value) async {
    if (!await _preferences.setInt(key, value)) {
      throw const StorageException();
    }
  }

  Future<void> setDouble(String key, double value) async {
    if (!await _preferences.setDouble(key, value)) {
      throw const StorageException();
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    if (!await _preferences.setStringList(key, value)) {
      throw const StorageException();
    }
  }

  Future<void> remove(String key) async {
    if (!await _preferences.remove(key)) {
      throw const StorageException();
    }
  }

  Future<void> clear() async {
    if (!await _preferences.clear()) {
      throw const StorageException();
    }
  }
}
