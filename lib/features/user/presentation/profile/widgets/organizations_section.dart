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
    final colors = AppColors.of(context);

    if (tenants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.corporate_fare_rounded, size: 40, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text('Sin organizaciones vinculadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
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
              Text('Ecosistema de organizaciones', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              if (tenants.length > 1)
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('Ver todas', style: TextStyle(fontSize: 13, color: colors.primary, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
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
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActiveWorkspace ? colors.primary.withOpacity(0.4) : colors.border, width: isActiveWorkspace ? 1.5 : 1.0),
                boxShadow: colors.subtleShadow(),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primary.withOpacity(0.1),
                    child: Text(
                      org.tenant.name.substring(0, math.min(2, org.tenant.name.length)).toUpperCase(),
                      style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isActiveWorkspace)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: colors.primary),
                                const SizedBox(width: 4),
                                Text('Espacio de trabajo activo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.primary)),
                              ],
                            ),
                          ),
                        Text(org.tenant.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
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
                  Icon(Icons.arrow_forward_rounded, size: 16, color: isActiveWorkspace ? colors.primary : colors.textSecondary),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
