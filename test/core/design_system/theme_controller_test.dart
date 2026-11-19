import 'package:RootOrg/core/design_system/themes/theme_controller.dart';
import 'package:RootOrg/core/storage/local_storage.dart';
import 'package:RootOrg/core/storage/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to system mode when no preference has been saved', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage(await SharedPreferences.getInstance());

    final controller = await ThemeController.load(storage);
    addTearDown(controller.dispose);

    expect(controller.themeMode, ThemeMode.system);
  });

  test('persists and restores a selected theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage(await SharedPreferences.getInstance());
    final controller = await ThemeController.load(storage);
    addTearDown(controller.dispose);

    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.setThemeMode(ThemeMode.dark);

    expect(storage.getString(StorageKeys.themeMode), 'dark');
    expect(controller.themeMode, ThemeMode.dark);
    expect(notifications, 1);

    final restoredController = await ThemeController.load(storage);
    addTearDown(restoredController.dispose);
    expect(restoredController.themeMode, ThemeMode.dark);
  });

  test('does not notify when selecting the current mode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage(await SharedPreferences.getInstance());
    final controller = await ThemeController.load(storage);
    addTearDown(controller.dispose);

    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.setThemeMode(ThemeMode.system);

    expect(notifications, 0);
  });
}
