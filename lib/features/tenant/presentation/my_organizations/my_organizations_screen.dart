import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/login/login_screen.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/my_unit_join_requests_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/roles_provider.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_shell_screen.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/shared/widgets/profile_incomplete_notice.dart';
import '../../domain/entities/join_request.dart';
import '../create_tenant/create_tenant_screen.dart';
import '../join_tenant/join_tenant_screen.dart';
import '../state/tenant_injection.dart';
import '../state/tenant_users_provider.dart';
import '../tenant_list/widgets/organization_card.dart';

/// Gate obligatorio tras el login, y centro de administración de la
/// relación usuario-organizaciones (ver docs/01-features/organizaciones.md
/// §"Mis Organizaciones"). Antes `SelectTenantScreen` -- evolucionó de "solo
/// elegir un tenant" a "organizaciones + acciones persistentes (crear/unirse)
/// + mis solicitudes de ingreso", pero conserva los dos modos vía
/// `isInitialSelection`:
///
/// - `true` (default) -- paso obligatorio tras el login, **siempre**, sin
///   importar cuántas organizaciones/solicitudes tenga el usuario (regla
///   explícita: nunca ir directo al Dashboard, ni con 0/1/2+ organizaciones,
///   ni justo después de crear una).
/// - `false` -- abierta a mitad de sesión desde `ShellHeader`/
///   `ShellHeaderMobile` para cambiar de organización activa.
class MyOrganizationsScreen extends StatefulWidget {
  final bool isInitialSelection;

  const MyOrganizationsScreen({super.key, this.isInitialSelection = true});

  @override
  State<MyOrganizationsScreen> createState() => _MyOrganizationsScreenState();
}

class _MyOrganizationsScreenState extends State<MyOrganizationsScreen> {
  List<JoinRequest> _requests = [];
  bool _loadingRequests = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    try {
      final requests = await TenantInjection.getMyJoinRequestsController().getMyJoinRequests(token);
      if (!mounted) return;
      setState(() {
        // Aprobada -> ya es una organización real, desaparece de aquí en el
        // próximo refresh. Cancelada -> la canceló el propio usuario, no
        // hace falta seguir mostrándola.
        _requests = requests
            .where((r) => r.status == JoinRequestStatus.pending || r.status == JoinRequestStatus.rejected)
            .toList();
        _loadingRequests = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRequests = false);
      debugPrint('Error cargando mis solicitudes: $e');
    }
  }

  void _enterShell(BuildContext context, {String? initialPushRoute}) {
    context.read<TenantSessionController>().markGatePassed();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShellScreen(initialPushRoute: initialPushRoute)),
      (route) => false,
    );
  }

  void _selectAndContinue(BuildContext context, UserTenant tenant) {
    context.read<TenantSessionController>().setActive(tenant);

    if (widget.isInitialSelection) {
      _enterShell(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _logout(BuildContext context) {
    context.read<TenantSessionController>().clear();
    context.read<OrganizationUnitsProvider>().clear();
    context.read<RolesProvider>().clear();
    context.read<PermissionsProvider>().clear();
    context.read<TenantUsersProvider>().clear();
    context.read<MyUnitJoinRequestsProvider>().clear();
    context.read<AuthProvider>().logout();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Crear/unirse ya **no** llevan directo al Dashboard -- ni crear una
  /// organización nueva ni, mucho menos, enviar una solicitud de ingreso
  /// (que ni siquiera da acceso inmediato). Ambas se empujan sobre esta
  /// misma pantalla y, al volver, el usuario elige explícitamente con qué
  /// organización continuar -- así se cumple la regla "nunca ir directo al
  /// Dashboard" incluso justo después de crear/pedir unirse.
  Future<void> _openCreateTenant(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateTenantScreen()));
  }

  Future<void> _openJoinTenant(BuildContext context) async {
    final requestSent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const JoinTenantScreen()),
    );
    if (requestSent == true) _loadRequests();
  }

  Future<void> _cancelRequest(BuildContext context, JoinRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar solicitud?'),
        content: Text('Se cancelará tu solicitud de ingreso a ${request.tenantName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    try {
      await TenantInjection.joinRequestActionsController().cancel(request.id, token);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud cancelada.')));
      _loadRequests();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().session?.user;
    final tenants = user?.tenants ?? [];

    if (widget.isInitialSelection && tenants.isEmpty && user?.isProfileComplete != true) {
      return _buildNoticeScaffold(
        context,
        ProfileIncompleteNotice(
          onCompleteProfile: () => _enterShell(context, initialPushRoute: AppRoutes.profile),
        ),
      );
    }

    return _buildMainScaffold(context, tenants);
  }

  Widget _buildNoticeScaffold(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(child: child),
    );
  }

  Widget _buildMainScaffold(BuildContext context, List<UserTenant> tenants) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: widget.isInitialSelection
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
        top: widget.isInitialSelection,
        child: RefreshIndicator(
          onRefresh: _loadRequests,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text('Mis Organizaciones', style: AppTypography.titleLarge.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tenants.isEmpty
                    ? 'Todavía no perteneces a ninguna organización.'
                    : tenants.length > 1
                        ? 'Perteneces a varias organizaciones. Elige con cuál quieres trabajar ahora.'
                        : 'Confirma para continuar con tu organización.',
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (tenants.isEmpty)
                _EmptyOrganizationsNotice(colors: colors)
              else
                for (final userTenant in tenants) ...[
                  OrganizationCard(
                    org: userTenant,
                    isRecent: false,
                    isOnlyOne: false,
                    onTap: () => _selectAndContinue(context, userTenant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              const SizedBox(height: AppSpacing.md),
              Text('Acciones', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_business_rounded,
                      label: 'Crear organización',
                      colors: colors,
                      onTap: () => _openCreateTenant(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.link_rounded,
                      label: 'Unirse mediante código',
                      colors: colors,
                      onTap: () => _openJoinTenant(context),
                    ),
                  ),
                ],
              ),
              if (!_loadingRequests && _requests.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text('Solicitudes', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.lg),
                for (final request in _requests) ...[
                  _JoinRequestRow(
                    request: request,
                    colors: colors,
                    onCancel: () => _cancelRequest(context, request),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              if (widget.isInitialSelection) ...[
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

class _EmptyOrganizationsNotice extends StatelessWidget {
  final AppPalette colors;

  const _EmptyOrganizationsNotice({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: colors.flatCardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderPill),
            child: Icon(Icons.apartment_outlined, color: colors.textMuted, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aquí aparecerán las organizaciones a las que perteneces.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette colors;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 22),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinRequestRow extends StatelessWidget {
  final JoinRequest request;
  final AppPalette colors;
  final VoidCallback onCancel;

  const _JoinRequestRow({required this.request, required this.colors, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bool isPending = request.status == JoinRequestStatus.pending;
    final Color badgeColor = isPending ? colors.warning : colors.danger;
    final String badgeLabel = isPending ? 'Pendiente' : 'Rechazada';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.tenantName,
                  style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: AppRadius.borderPill),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatRequestedAt(request.requestedAt),
                      style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            TextButton(
              onPressed: onCancel,
              child: Text('Cancelar', style: TextStyle(color: colors.danger, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  String _formatRequestedAt(DateTime date) {
    return 'Enviada el ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
