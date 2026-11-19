import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_tokens.dart';
import '../models/app_user_model.dart';
import '../models/login_response_model.dart';

abstract final class AuthMapper {
  static AuthSession toSession(LoginResponseModel model, {DateTime? now}) {
    return model.toEntity(now: now);
  }

  static AuthSession toRestoredSession({
    required AppUserModel user,
    required bool hasOrganizationUnit,
    required AuthTokens tokens,
  }) {
    return AuthSession(
      user: user.toEntity(),
      hasOrganizationUnit: hasOrganizationUnit,
      accessTokenExpiresAt: tokens.accessTokenExpiresAt,
    );
  }
}
