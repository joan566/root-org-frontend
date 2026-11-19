import 'package:RootOrg/features/auth/presentation/state/auth_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates email and backend password requirements', () {
    expect(AuthValidation.email('person@example.com'), isNull);
    expect(AuthValidation.email('not-an-email'), isNotNull);
    expect(AuthValidation.email('${'a' * 146}@example.com'), isNotNull);

    expect(AuthValidation.password('ValidPass1'), isNull);
    expect(AuthValidation.password('alllowercase1'), isNotNull);
    expect(AuthValidation.password('NoDigitPassword'), isNotNull);
    expect(AuthValidation.confirmation('Different1', 'ValidPass1'), isNotNull);
  });
}
