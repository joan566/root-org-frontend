import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';

class User {
  final int id;
  final String name;
  final String? lastName;
  final String? document;
  final DateTime? dateOfBirth;
  final String? gender;
  final String email;
  final String phoneNumber;
  final String status;
  final String profileStatus;
  final List<UserTenant> tenants;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.document,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.profileStatus,
    required this.tenants,
    required this.createdAt,
    required this.updatedAt
  });

  /// Fuente única de verdad para "perfil completo" en todo el frontend.
  /// No usar `profileStatus` (string cruda del backend) para esto: su
  /// formato es inconsistente entre lo que compara el código ('COMPLETED')
  /// y el ejemplo documentado en ADR-011 ('Completo') — nunca coinciden.
  bool get isProfileComplete =>
      name.isNotEmpty &&
      (lastName?.isNotEmpty ?? false) &&
      (document?.isNotEmpty ?? false) &&
      phoneNumber.isNotEmpty &&
      dateOfBirth != null &&
      (gender?.isNotEmpty ?? false);

  /// Cantidad de los 6 campos personales que faltan (0-6).
  int get missingProfileFieldsCount {
    int pending = 0;
    if (name.isEmpty) pending++;
    if (!(lastName?.isNotEmpty ?? false)) pending++;
    if (!(document?.isNotEmpty ?? false)) pending++;
    if (phoneNumber.isEmpty) pending++;
    if (dateOfBirth == null) pending++;
    if (!(gender?.isNotEmpty ?? false)) pending++;
    return pending;
  }

  /// Avance del perfil personal (0.0-1.0).
  double get profileCompletionRatio => (6 - missingProfileFieldsCount) / 6;
}