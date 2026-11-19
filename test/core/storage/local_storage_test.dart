import 'package:RootOrg/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists and removes typed values', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage(await SharedPreferences.getInstance());

    await storage.setString('sample', 'value');
    await storage.setBool('enabled', true);
    await storage.setInt('count', 3);

    expect(storage.getString('sample'), 'value');
    expect(storage.getBool('enabled'), isTrue);
    expect(storage.getInt('count'), 3);

    await storage.remove('sample');
    expect(storage.getString('sample'), isNull);
  });
}
