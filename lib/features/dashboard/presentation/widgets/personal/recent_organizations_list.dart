import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

import '../../../../auth/domain/entities/user_tenant.dart';
import '../../../../auth/presentation/provider/auth_provider.dart';


class RecentOrganizationsList extends StatelessWidget {
  const RecentOrganizationsList({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuchar la sesión del usuario real
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;

    // 2. Obtener la lista de UserTenants reales
    final List<UserTenant> userTenants = currentUser?.tenants ?? [];

    if (userTenants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppColors.translucentCardDecoration(radius: 24),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No tienes organizaciones vinculadas todavía.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppColors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Organizaciones vinculadas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Ver todas (${userTenants.length})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userTenants.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final userTenant = userTenants[index];
              final tenant = userTenant.tenant;

              // Evaluamos dinámicamente si el estado en la base de datos es "ACTIVE"
              final bool isActive = userTenant.status.toUpperCase() == 'ACTIVE';

              // Iniciales seguras para el avatar de la organización
              final String initialLetter = tenant.name.isNotEmpty
                  ? tenant.name[0].toUpperCase()
                  : 'O';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.background,
                      child: Text(
                        initialLetter,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              // Muestra los roles reales del usuario dentro del tenant (ej: ADMIN, MEMBER)
                              Text(
                                _translateRoles(userTenant.roles),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              // Código único de organización
                              Text(
                                'Code: ${tenant.code}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryLight : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: isActive ? AppColors.primaryDark : const Color(0xFFC2410C),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        // Navegar al detalle de esta organización específica si lo requieres
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Traducción visual de los roles del backend a texto de cara al usuario
  String _translateRoles(List<String> roles) {
    if (roles.isEmpty) return 'Sin rol';
    return roles.map(_translateRole).join(', ');
  }

  String _translateRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
      case 'OWNER':
        return 'Administrador';
      case 'MEMBER':
        return 'Miembro';
      case 'COLLABORATOR':
        return 'Colaborador';
      case 'AUDITOR':
        return 'Auditor Interno';
      default:
        return role;
    }
  }
}