import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';

class UpdateProfile {
  final bool successfully;
  final String message;
  final User user;

  UpdateProfile({
    required this.successfully,
    required this.message,
    required this.user
  });
}