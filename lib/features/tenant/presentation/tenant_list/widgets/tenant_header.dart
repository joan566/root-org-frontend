import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/shared/widgets/header_clipper.dart';

class TenantHeader extends StatelessWidget {
  final String userName;
  final int totalOrgs;
  final int activeOrgs;
  final String primaryRole;

  const TenantHeader({
    super.key,
    required this.userName,
    required this.totalOrgs,
    required this.activeOrgs,
    required this.primaryRole,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 290 + statusBarHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hola $userName',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tus organizaciones',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona la organización con la que deseas trabajar.',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: -30,
          child: _StatsCard(
            totalOrgs: totalOrgs,
            activeOrgs: activeOrgs,
            primaryRole: primaryRole,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int totalOrgs;
  final int activeOrgs;
  final String primaryRole;

  const _StatsCard({
    required this.totalOrgs,
    required this.activeOrgs,
    required this.primaryRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.floatingShadow(),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.grid_view_rounded, 'Total Orgs', totalOrgs.toString()),
          Container(width: 1, height: 35, color: AppColors.border),
          _buildStatItem(Icons.verified_user_rounded, 'Rol Principal', primaryRole),
          Container(width: 1, height: 35, color: AppColors.border),
          _buildStatItem(Icons.check_circle_rounded, 'Activas', '$activeOrgs/$totalOrgs'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
