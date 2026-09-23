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

/// Header superior del shell (solo Desktop, ver
/// docs/01-features/shell-y-navegacion.md). Antes del rediseño no existía un
/// header a nivel shell -- vivía dentro de `DashboardGeneralScreen`
/// (`HeaderUserBlock`), que se mantiene para la vista mobile/tablet.
class ShellHeader extends StatelessWidget {
  const ShellHeader({super.key});

  String _initials(String name) => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  String _primaryRoleLabel(List<String> rawRoles) {
    if (rawRoles.isEmpty) return 'Colaborador';
    switch (rawRoles.first.toUpperCase()) {
      case 'OWNER':
        return 'Propietario';
      case 'ADMIN':
        return 'Admin';
      case 'MEMBER':
      case 'USER':
        return 'Colaborador';
      default:
        return rawRoles.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authProvider = context.watch<AuthProvider>();
    final tenantSession = context.watch<TenantSessionController>();
    final currentUser = authProvider.session?.user;
    final tenantsList = currentUser?.tenants ?? [];
    final activeTenant = tenantSession.resolveActive(tenantsList);
    final bool canSwitchOrganization = tenantsList.length > 1;
    final bool isActiveMembership = activeTenant?.status.toUpperCase() == 'ACTIVE';
    final userName = currentUser?.name ?? 'Usuario';

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: colors.subtleShadow(),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: colors.slateDark, borderRadius: AppRadius.borderSm),
            child: Icon(Icons.blur_on_outlined, color: colors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          if (activeTenant != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                activeTenant.tenant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
              ),
            ),
            if (isActiveMembership) ...[
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(label: 'Activa', color: colors.success),
            ],
          ],
          const SizedBox(width: AppSpacing.xxl),
          Expanded(child: _SearchBarPlaceholder(colors: colors)),
          const SizedBox(width: AppSpacing.xxl),
          _IconButtonPlaceholder(icon: Icons.notifications_outlined, tooltip: 'Notificaciones (próximamente)'),
          const SizedBox(width: AppSpacing.sm),
          _IconButtonPlaceholder(icon: Icons.mail_outline, tooltip: 'Mensajes (próximamente)'),
          const SizedBox(width: AppSpacing.lg),
          Container(width: 1, height: 32, color: colors.border),
          const SizedBox(width: AppSpacing.lg),
          if (canSwitchOrganization)
            _OrganizationSwitcher(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyOrganizationsScreen(isInitialSelection: false)),
              ),
            ),
          if (canSwitchOrganization) const SizedBox(width: AppSpacing.lg),
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primary.withOpacity(0.15),
            child: Text(
              _initials(userName),
              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                _primaryRoleLabel(activeTenant?.roles ?? const []),
                style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Buscador decorativo: sin lógica ni backend todavía (ver
/// docs/01-features/shell-y-navegacion.md), mismo patrón honesto que
/// `UpcomingModulesSection` -- se ve, pero no hace nada al escribir.
class _SearchBarPlaceholder extends StatelessWidget {
  final AppPalette colors;

  const _SearchBarPlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        enabled: false,
        style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        decoration: InputDecoration(
          hintText: 'Buscar usuarios, módulos, reportes...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textMuted),
          prefixIcon: Icon(Icons.search_outlined, size: 20, color: colors.textMuted),
          filled: true,
          fillColor: colors.background,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: AppRadius.borderPill, borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _IconButtonPlaceholder extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _IconButtonPlaceholder({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderMd),
        child: Icon(icon, size: 19, color: colors.textSecondary),
      ),
    );
  }
}

class _OrganizationSwitcher extends StatelessWidget {
  final VoidCallback onTap;

  const _OrganizationSwitcher({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Cambiar',
                style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
