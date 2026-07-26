import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'role_Chip.dart';
import 'status_chip.dart';

class OrganizationsSection extends StatelessWidget {
  final List<dynamic> tenants;

  const OrganizationsSection({super.key, required this.tenants});

  @override
  Widget build(BuildContext context) {
    if (tenants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.corporate_fare_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('Sin organizaciones vinculadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Crear')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () {}, child: const Text('Unirme')),
              ],
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ecosistema de organizaciones', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (tenants.length > 1)
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Text('Ver todas', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                )
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tenants.length,
          itemBuilder: (context, index) {
            final org = tenants[index];
            final bool isActiveWorkspace = index == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActiveWorkspace ? AppColors.primary.withOpacity(0.4) : AppColors.border, width: isActiveWorkspace ? 1.5 : 1.0),
                boxShadow: AppColors.subtleShadow(),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      org.tenant.name.substring(0, math.min(2, org.tenant.name.length)).toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isActiveWorkspace)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text('Espacio de trabajo activo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        Text(org.tenant.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            RoleChip(roles: org.roles),
                            const SizedBox(width: 6),
                            StatusChip(status: org.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: isActiveWorkspace ? AppColors.primary : AppColors.textSecondary),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
