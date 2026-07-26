
import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';

class LoginSesion {
  final String token;
  bool hasTenant;
  final User user;

  LoginSesion({
    required this.token,
    required this.hasTenant,
    required this.user,
  });
}