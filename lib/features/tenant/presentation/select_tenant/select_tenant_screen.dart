import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/login/login_screen.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/dashboard/presentation/dashboard_general/widgets/no_active_organization_card.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_shell_screen.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/shared/widgets/profile_incomplete_notice.dart';
import '../tenant_list/widgets/organization_card.dart';

/// Gate obligatorio de selección de organización tras el login, y selector
/// de cambio de organización a mitad de sesión (ver
/// docs/frontend-navigation-redesign.md §2 y §6). Dos usos:
///
/// - `isInitialSelection: true` (default) — paso "Selección de Tenant" del
///   login: **siempre** se muestra tras iniciar sesión, sin importar cuántas
///   organizaciones tenga el usuario. Tres estados según los datos reales:
///   1. Perfil incompleto → `ProfileIncompleteNotice`.
///   2. Perfil completo, 0 organizaciones → `NoActiveOrganizationView`.
///   3. 1+ organizaciones → lista (`OrganizationCard`), con confirmación
///      explícita incluso con una sola.
///   Cualquiera de los 3 entra al shell vía `_enterShell`, que marca
///   `TenantSessionController.markGatePassed()` y reemplaza toda la pila
///   con un `MainShellScreen` nuevo (opcionalmente con `initialPushRoute`
///   para aterrizar directo en Perfil/Crear/Unirse).
/// - `isInitialSelection: false` — abierta desde el Dashboard General
///   (`HeaderUserBlock`) para cambiar de organización a mitad de sesión
///   (solo cuando el usuario ya tiene 2+): se empuja sobre el navigator
///   interno del shell, con botón de retroceso, y al elegir simplemente
///   hace `pop` — el Dashboard ya escucha `TenantSessionController` y se
///   actualiza solo.
class SelectTenantScreen extends StatelessWidget {
  final bool isInitialSelection;

  const SelectTenantScreen({super.key, this.isInitialSelection = true});

  void _enterShell(BuildContext context, {String? initialPushRoute}) {
    context.read<TenantSessionController>().markGatePassed();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShellScreen(initialPushRoute: initialPushRoute)),
      (route) => false,
    );
  }

  void _selectAndContinue(BuildContext context, UserTenant tenant) {
    context.read<TenantSessionController>().setActive(tenant);

    if (isInitialSelection) {
      _enterShell(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _logout(BuildContext context) {
    context.read<TenantSessionController>().clear();
    context.read<AuthProvider>().logout();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().session?.user;
    final tenants = user?.tenants ?? [];

    if (!isInitialSelection) {
      return _buildTenantListScaffold(context, tenants);
    }

    // Entrar a una organización ya existente no requiere perfil completo —
    // eso solo bloquea CREAR/UNIRSE (ver CreateTenantScreen/JoinTenantScreen).
    // Por eso esta condición se evalúa antes que la de perfil.
    if (tenants.isNotEmpty) {
      return _buildTenantListScaffold(context, tenants);
    }

    if (user?.isProfileComplete != true) {
      return _buildNoticeScaffold(
        context,
        ProfileIncompleteNotice(
          onCompleteProfile: () => _enterShell(context, initialPushRoute: AppRoutes.profile),
        ),
      );
    }

    return _buildNoticeScaffold(
      context,
      NoActiveOrganizationView(
        onCreateOrganization: () => _enterShell(context, initialPushRoute: AppRoutes.createTenant),
        onJoinOrganization: () => _enterShell(context, initialPushRoute: AppRoutes.joinTenant),
      ),
    );
  }

  Widget _buildNoticeScaffold(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(child: child),
    );
  }

  Widget _buildTenantListScaffold(BuildContext context, List<UserTenant> tenants) {
    final colors = AppColors.of(context);

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
                tenants.length > 1
                    ? 'Perteneces a varias organizaciones. Elige con cuál quieres trabajar ahora.'
                    : 'Confirma para continuar con tu organización.',
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
