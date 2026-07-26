import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';

class GetUser {
  final bool successfully;
  final String message;
  final User user;

  GetUser({
    required this.successfully,
    required this.message,
    required this.user
  });
}