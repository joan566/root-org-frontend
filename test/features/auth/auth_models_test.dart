import 'package:RootOrg/features/auth/data/mappers/auth_mapper.dart';
import 'package:RootOrg/features/auth/data/models/app_user_model.dart';
import 'package:RootOrg/features/auth/data/models/auth_token_response_model.dart';
import 'package:RootOrg/features/auth/data/models/auth_response_exception.dart';
import 'package:RootOrg/features/auth/data/models/login_response_model.dart';
import 'package:RootOrg/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps email verification from the current-user profile', () {
    final user = AppUserModel.fromJson({
      'id': 42,
      'userEmail': 'ana@example.com',
      'emailVerified': true,
      'organizationUnitMemberInfos': [],
    });
    final session = AuthMapper.toRestoredSession(
      user: user,
      hasOrganizationUnit: false,
      tokens: AuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        accessTokenExpiresAt: DateTime.utc(2027),
      ),
    );

    expect(session.user.emailVerified, isTrue);
  });

  test('preserves an unverified status from the current-user profile', () {
    final user = AppUserModel.fromJson({
      'id': 42,
      'userEmail': 'ana@example.com',
      'emailVerified': false,
      'organizationUnitMemberInfos': [],
    });

    expect(user.toEntity().emailVerified, isFalse);
  });

  test('rejects user profiles without email verification status', () {
    expect(
      () => AppUserModel.fromJson({
        'id': 42,
        'userEmail': 'ana@example.com',
        'organizationUnitMemberInfos': [],
      }),
      throwsFormatException,
    );
  });

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
        'emailVerified': true,
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
    expect(session.user.emailVerified, isTrue);
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
