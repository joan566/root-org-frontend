
import 'package:savings_api_frontend/features/auth/data/mappers/user_tenant_mapper.dart';
import 'package:savings_api_frontend/features/auth/data/models/user_model.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';

class UserMapper {
  static User toDomain(UserModel model) {
    return User(
      id: model.id,
      name: model.name,
      lastName: model.lastName,
      document: model.document,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      email: model.email,
      phoneNumber: model.phoneNumber,
      status: model.status,
      profileStatus: model.profileStatus,
      tenants: model.tenants
          .map(UserTenantMapper.toDomain)
          .toList(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}