import 'app_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.hasOrganizationUnit,
    required this.accessTokenExpiresAt,
  });

  final AppUser user;
  final bool hasOrganizationUnit;
  final DateTime accessTokenExpiresAt;
}
