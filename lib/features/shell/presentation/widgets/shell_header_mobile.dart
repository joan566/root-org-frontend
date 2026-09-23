import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/my_organizations/my_organizations_screen.dart';

/// Header a nivel Shell, exclusivo de Mobile -- versión compacta de
/// [ShellHeader] (Desktop). Se monta una vez en `MainShellScreen` y queda
/// visible en las 5 secciones, reemplazando por completo a la extinta
/// `DashboardHeaderMobile` (que solo vivía dentro del tab Dashboard): mismo
/// contenido -- organización activa + selector, notificaciones, avatar --
/// pero ahora siempre alcanzable, igual que en Desktop.
class ShellHeaderMobile extends StatelessWidget {
  const ShellHeaderMobile({super.key});

  String _initials(String name) => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authProvider = context.watch<AuthProvider>();
    final tenantSession = context.watch<TenantSessionController>();
    final currentUser = authProvider.session?.user;
    final tenantsList = currentUser?.tenants ?? const [];
    final activeTenant = tenantSession.resolveActive(tenantsList);
    final bool canSwitchOrganization = tenantsList.length > 1;
    final userName = currentUser?.name ?? 'Usuario';

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(color: colors.surface, boxShadow: colors.subtleShadow()),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: colors.slateDark, borderRadius: AppRadius.borderSm),
              child: Icon(Icons.blur_on_rounded, color: colors.primary, size: 15),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                activeTenant?.tenant.name ?? 'Sin organización',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
              ),
            ),
            if (canSwitchOrganization) ...[
              const SizedBox(width: AppSpacing.sm),
              _SwitchOrganizationButton(
                colors: colors,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyOrganizationsScreen(isInitialSelection: false)),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
            Tooltip(
              message: 'Notificaciones (próximamente)',
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderMd),
                child: Icon(Icons.notifications_outlined, size: 17, color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 15,
              backgroundColor: colors.primary.withOpacity(0.15),
              child: Text(
                _initials(userName),
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchOrganizationButton extends StatelessWidget {
  final AppPalette colors;
  final VoidCallback onTap;

  const _SwitchOrganizationButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_outlined, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text('Cambiar', style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
