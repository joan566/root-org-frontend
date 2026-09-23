import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user.dart';
import 'package:savings_api_frontend/features/auth/domain/entities/user_tenant.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant.dart';
import 'package:savings_api_frontend/shared/layouts/coming_soon_screen.dart';
import 'bottom_sheets/edit_organization_bottom_sheet.dart';
import 'state/organization_capabilities.dart';
import 'widgets/membership_info_tab.dart';
import 'widgets/organization_info_tab.dart';
import 'widgets/structure/structure_tab.dart';
import 'widgets/structure_member/structure_member_tab.dart';
import 'widgets/users/invite_user_bottom_sheet.dart';
import 'widgets/users/users_tab.dart';

/// Sección "Organización" del shell (ver docs/frontend-navigation-redesign.md
/// §3.1 y docs/01-features/organizacion.md). Las pestañas dependen de
/// [OrganizationCapabilities] (aproximación cosmética vía `roles`, ver ese
/// archivo): un Admin ve Información/Usuarios/Roles/Estructura; un Member ve
/// Información/Estructura Organizacional/Mi membresía — nunca las pestañas
/// administrativas bloqueadas con un candado.
///
/// "Estructura" (Admin) es [StructureTab], respaldada por
/// `/organization-units` (feature `organization_unit`). "Estructura
/// Organizacional" (Member) es [StructureMemberTab] -- misma fuente de datos
/// (`OrganizationUnitsProvider`, compartida con el Admin), más el ciclo de
/// vida de la solicitud de ingreso propia del usuario
/// (`MyUnitJoinRequestsProvider`). Sin FAB: las acciones viven inline en las
/// cards/detalle, `_buildFab` ya retorna `null` para no-admins.
class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool? _isAdmin;
  int? _permissionsRequestedForTenant;
  final _structureTabKey = GlobalKey<StructureTabState>();

  static const int _infoTabIndex = 0;
  static const int _adminUsersTabIndex = 1;
  static const int _adminStructureTabIndex = 3;

  /// ADR-021: `GET /me/permissions?tenantId=` (sin unidad) -- se dispara una
  /// sola vez por tenant activo, igual que el resto de los caches por
  /// tenant de la app (`RolesProvider`, `OrganizationUnitsProvider`).
  void _ensurePermissionsLoaded(int? tenantId) {
    if (tenantId == null) return;
    final provider = context.read<PermissionsProvider>();
    if (provider.isTenantLoaded(tenantId)) return;
    if (_permissionsRequestedForTenant == tenantId) return;
    _permissionsRequestedForTenant = tenantId;
    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;
    provider.loadForTenant(tenantId, token).catchError((_) {
      _permissionsRequestedForTenant = null;
    });
  }

  void _ensureController(bool isAdmin) {
    if (_isAdmin == isAdmin && _tabController != null) return;
    _tabController?.dispose();
    _isAdmin = isAdmin;
    _tabController = TabController(length: isAdmin ? 4 : 3, vsync: this)
      ..addListener(() {
        if (!_tabController!.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _openInvite(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InviteUserBottomSheet(),
    );
  }

  /// Abre el formulario de edición y, si se guardó con éxito, reconstruye
  /// `AuthProvider.session.user` con el `Tenant` actualizado -- el backend
  /// de `PUT /tenant/{id}` solo devuelve el tenant, no el `User` completo,
  /// a diferencia de `update-profile` (ver `EditProfileBottomSheet`).
  Future<void> _openEditOrganization(BuildContext context, UserTenant activeTenant) async {
    final updated = await showModalBottomSheet<Tenant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditOrganizationBottomSheet(
        tenantId: activeTenant.tenant.id,
        initialName: activeTenant.tenant.name,
        initialDescription: activeTenant.tenant.description,
      ),
    );
    if (updated == null || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final user = auth.session!.user;
    final updatedTenants = user.tenants
        .map((ut) => ut.tenant.id == updated.id
            ? UserTenant(id: ut.id, tenant: updated, userId: ut.userId, roles: ut.roles, status: ut.status)
            : ut)
        .toList();

    auth.updateUser(User(
      id: user.id,
      name: user.name,
      lastName: user.lastName,
      document: user.document,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      email: user.email,
      phoneNumber: user.phoneNumber,
      status: user.status,
      profileStatus: user.profileStatus,
      tenants: updatedTenants,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    ));
  }

  Widget? _buildFab(BuildContext context, AppPalette colors, OrganizationCapabilities capabilities, UserTenant? activeTenant) {
    if (!capabilities.isAdmin) return null;
    final index = _tabController!.index;

    if (index == _infoTabIndex && activeTenant != null) {
      return FloatingActionButton.extended(
        onPressed: () => _openEditOrganization(context, activeTenant),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar organización'),
        backgroundColor: colors.primary,
      );
    }
    if (index == _adminUsersTabIndex) {
      return FloatingActionButton.extended(
        onPressed: () => _openInvite(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Invitar usuario'),
        backgroundColor: colors.primary,
      );
    }
    if (index == _adminStructureTabIndex && capabilities.canManageOrganizationStructure) {
      return FloatingActionButton.extended(
        onPressed: () => _structureTabKey.currentState?.openCreate(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear departamento'),
        backgroundColor: colors.primary,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tenants = context.watch<AuthProvider>().session?.user.tenants ?? [];
    final activeTenant = context.watch<TenantSessionController>().resolveActive(tenants);
    final tenantId = activeTenant?.tenant.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermissionsLoaded(tenantId));
    final permissionCodes = tenantId == null ? const <String>{} : context.watch<PermissionsProvider>().codesForTenant(tenantId);
    final capabilities = OrganizationCapabilities(activeTenant?.roles ?? const [], permissionCodes);

    _ensureController(capabilities.isAdmin);
    final tabController = _tabController!;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: _buildFab(context, colors, capabilities, activeTenant),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.md),
              child: Text(
                'Organización',
                style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
              ),
            ),
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: colors.primary,
              labelStyle: AppTypography.labelLarge,
              tabs: capabilities.isAdmin
                  ? const [
                      Tab(text: 'Información'),
                      Tab(text: 'Usuarios'),
                      Tab(text: 'Roles'),
                      Tab(text: 'Estructura'),
                    ]
                  : const [
                      Tab(text: 'Información'),
                      Tab(text: 'Estructura Organizacional'),
                      Tab(text: 'Mi membresía'),
                    ],
            ),
            Divider(color: colors.border, height: 1),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: capabilities.isAdmin
                    ? [
                        const OrganizationInfoTab(),
                        const UsersTab(),
                        const ComingSoonView(
                          title: 'Roles',
                          description:
                              'La administración de roles (crear roles personalizados, asignar permisos) está explícitamente fuera de alcance del backend por ahora.',
                          icon: Icons.shield_outlined,
                        ),
                        StructureTab(key: _structureTabKey),
                      ]
                    : const [
                        OrganizationInfoTab(),
                        StructureMemberTab(),
                        MembershipInfoTab(),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
