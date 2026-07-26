import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';

import '../../../../auth/domain/entities/user_tenant.dart';
import '../../../../auth/presentation/provider/auth_provider.dart';

/// Selector rápido de organización activa (ver
/// docs/frontend-navigation-redesign.md §6 — antes listaba "organizaciones
/// vinculadas" sin acción real; ahora tocar una organización distinta de
/// la activa la activa). El badge "Activo/Inactivo" es el estado de
/// membresía que reporta el backend (`userTenant.status`) — un concepto
/// distinto de "cuál está activa en esta sesión", que se indica aparte.
class RecentOrganizationsList extends StatelessWidget {
  const RecentOrganizationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;
    final tenantSession = context.watch<TenantSessionController>();

    final List<UserTenant> userTenants = currentUser?.tenants ?? [];
    final colors = AppColors.of(context);
    final activeTenant = tenantSession.resolveActive(userTenants);

    if (userTenants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: colors.translucentCardDecoration(radius: 24),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No tienes organizaciones vinculadas todavía.',
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: colors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus organizaciones',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              Text(
                '${userTenants.length} en total',
                style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (userTenants.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              'Toca una organización para activarla.',
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
          ],
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userTenants.length,
            separatorBuilder: (context, index) => Divider(color: colors.border, height: 1),
            itemBuilder: (context, index) {
              final userTenant = userTenants[index];
              final tenant = userTenant.tenant;
              final bool isCurrentlyActive = activeTenant?.id == userTenant.id;

              // Estado de membresía reportado por el backend (distinto de "activa en esta sesión")
              final bool isMemberActive = userTenant.status.toUpperCase() == 'ACTIVE';

              final String initialLetter = tenant.name.isNotEmpty
                  ? tenant.name[0].toUpperCase()
                  : 'O';

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isCurrentlyActive
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        context.read<TenantSessionController>().setActive(userTenant);
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isCurrentlyActive ? colors.primaryLight : colors.background,
                        child: Text(
                          initialLetter,
                          style: TextStyle(
                            color: isCurrentlyActive ? colors.primaryDark : colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  _translateRoles(userTenant.roles),
                                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(color: colors.textMuted, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Code: ${tenant.code}',
                                  style: TextStyle(fontSize: 11, color: colors.textMuted),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMemberActive ? colors.primaryLight : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isMemberActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: isMemberActive ? colors.primaryDark : const Color(0xFFC2410C),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isCurrentlyActive)
                        Tooltip(
                          message: 'Organización activa',
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded, size: 16, color: colors.primary),
                          ),
                        )
                      else
                        Tooltip(
                          message: 'Activar esta organización',
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.swap_horiz_rounded, size: 16, color: colors.textSecondary),
                          ),
                        ),
                    ],
                  ),
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
