import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_shell_screen.dart';
import '../tenant_list/widgets/organization_card.dart';

/// Paso "Selección de Tenant" del flujo de login (ver
/// docs/frontend-navigation-redesign.md §2). Solo aparece cuando el usuario
/// pertenece a 2+ organizaciones y ninguna fue elegida como activa todavía
/// — con 0 o 1 organización, `MainApp` resuelve la organización activa
/// automáticamente y esta pantalla no se muestra.
class SelectTenantScreen extends StatelessWidget {
  const SelectTenantScreen({super.key});

  void _selectAndContinue(BuildContext context, UserTenant tenant) {
    context.read<TenantSessionController>().setActive(tenant);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  void _logout(BuildContext context) {
    context.read<TenantSessionController>().clear();
    context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenants = context.watch<AuthProvider>().session?.user.tenants ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona tu organización',
                style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Perteneces a varias organizaciones. Elige con cuál quieres trabajar ahora.',
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: ListView.separated(
                  itemCount: tenants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final userTenant = tenants[index];
                    return OrganizationCard(
                      org: userTenant,
                      isRecent: false,
                      isOnlyOne: false,
                      onTap: () => _selectAndContinue(context, userTenant),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => _logout(context),
                  child: Text(
                    'Cerrar sesión',
                    style: AppTypography.labelLarge.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
