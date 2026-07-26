import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_shell_screen.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import '../tenant_list/widgets/organization_card.dart';

/// Selección/cambio de organización activa (ver
/// docs/frontend-navigation-redesign.md §2 y §6). Dos usos:
///
/// - `isInitialSelection: true` (default) — paso "Selección de Tenant" del
///   login: aparece solo cuando el usuario pertenece a 2+ organizaciones y
///   ninguna fue elegida como activa. Al elegir, reemplaza toda la pila con
///   un `MainShellScreen` nuevo (mismo comportamiento que iniciar sesión).
/// - `isInitialSelection: false` — abierta desde el Dashboard General
///   (`HeaderUserBlock`) para cambiar de organización a mitad de sesión: se
///   empuja sobre el navigator interno del shell, con botón de retroceso, y
///   al elegir simplemente hace `pop` — el Dashboard ya escucha
///   `TenantSessionController` y se actualiza solo.
class SelectTenantScreen extends StatelessWidget {
  final bool isInitialSelection;

  const SelectTenantScreen({super.key, this.isInitialSelection = true});

  void _selectAndContinue(BuildContext context, UserTenant tenant) {
    context.read<TenantSessionController>().setActive(tenant);

    if (isInitialSelection) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
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
      appBar: isInitialSelection
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leadingWidth: 80,
              leading: const Padding(
                padding: EdgeInsets.only(left: 20, top: 4, bottom: 4),
                child: AppBackButton(),
              ),
            ),
      body: SafeArea(
        top: isInitialSelection,
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
              if (isInitialSelection) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
