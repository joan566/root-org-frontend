import 'package:RootOrg/features/auth/data/models/auth_token_response_model.dart';
import 'package:RootOrg/features/auth/data/models/auth_response_exception.dart';
import 'package:RootOrg/features/auth/data/models/login_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps login token lifetime from seconds and organization-unit flag', () {
    final now = DateTime.utc(2026, 11, 19, 12);
    final response = LoginResponseModel.fromJson({
      'successfully': true,
      'message': 'ok',
      'token': 'access',
      'refreshToken': 'refresh',
      'expiresIn': 900,
      'hasOrganizationUnit': true,
      'user': {
        'id': 42,
        'name': 'Ana',
        'lastName': 'Lopez',
        'userEmail': 'ana@example.com',
        'organizationUnitMemberInfos': [
          {
            'id': 3,
            'organizationUnitId': 7,
            'userId': 42,
            'status': 'ACTIVE',
            'joinedAt': '2026-01-01',
          },
        ],
      },
    });

    final session = response.toEntity(now: now);

    expect(session.user.id, 42);
    expect(session.user.email, 'ana@example.com');
    expect(session.hasOrganizationUnit, isTrue);
    expect(session.accessTokenExpiresAt, now.add(const Duration(seconds: 900)));
    expect(
      session.user.organizationUnitMemberships.single.organizationUnitId,
      7,
    );
  });

  test('rejects login responses missing the renamed organization field', () {
    expect(
      () => LoginResponseModel.fromJson({
        'successfully': true,
        'token': 'access',
        'refreshToken': 'refresh',
        'expiresIn': 900,
        'hasTenant': true,
        'user': {'id': 42},
      }),
      throwsA(isA<AuthResponseException>()),
    );
  });

  test('rejects unsuccessful or malformed refresh responses', () {
    expect(
      () => AuthTokenResponseModel.fromJson({
        'successfully': false,
        'token': 'access',
        'refreshToken': 'refresh',
        'expiresIn': 900,
      }),
      throwsA(isA<AuthResponseException>()),
    );
  });
}
