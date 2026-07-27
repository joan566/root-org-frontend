import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_injection.dart';

import 'invite_user_bottom_sheet.dart';
import 'pending_join_requests_screen.dart';
import 'user_card.dart';
import 'user_detail_bottom_sheet.dart';
import 'user_filters_bottom_sheet.dart';
import 'users_skeleton_loader.dart';

/// Pestaña "Usuarios" de Organización (ver docs/01-features/organizacion.md).
/// Solo administra membresía -- no roles/permisos (eso vive en otra
/// sección). Lista real vía `GET /tenant/{id}/users`; banner + pantalla de
/// solicitudes pendientes reales vía los endpoints de
/// docs/01-features/organizaciones.md; invitar/desasociar son honestos
/// "Próximamente" -- no existe backend para esas dos acciones todavía.
class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> with AutomaticKeepAliveClientMixin<UsersTab> {
  @override
  bool get wantKeepAlive => true;

  bool _loading = true;
  Object? _error;
  List<TenantMember> _members = [];
  int _pendingRequestsCount = 0;

  final _searchController = TextEditingController();
  String _query = '';
  UserStatusFilter _statusFilter = UserStatusFilter.all;
  Set<String> _selectedRoles = {};
  UserSortMode _sortMode = UserSortMode.nameAsc;

  int? get _tenantId {
    final auth = context.read<AuthProvider>();
    final tenants = auth.session?.user.tenants ?? [];
    final active = context.read<TenantSessionController>().resolveActive(tenants);
    return active?.tenant.id;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final tenantId = _tenantId;
    final token = context.read<AuthProvider>().session?.token;
    if (tenantId == null || token == null) {
      setState(() {
        _loading = false;
        _error = Exception('No hay una organización activa.');
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final members = await TenantInjection.getTenantUsersController().getTenantUsers(tenantId, token);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }

    // Contador de solicitudes pendientes -- solo lo puede ver un admin
    // (`core.tenant.join_request.read`). Si el usuario no lo es, el 403 se
    // ignora en silencio y el banner simplemente no aparece; no es un error
    // que deba bloquear la lista de miembros.
    try {
      final pending = await TenantInjection.getPendingJoinRequestsController().getPendingJoinRequests(tenantId, token);
      if (!mounted) return;
      setState(() => _pendingRequestsCount = pending.length);
    } catch (_) {
      if (!mounted) return;
      setState(() => _pendingRequestsCount = 0);
    }
  }

  List<TenantMember> get _filteredMembers {
    final result = _members.where((m) {
      if (_statusFilter == UserStatusFilter.active && m.status.toUpperCase() != 'ACTIVE') return false;
      if (_selectedRoles.isNotEmpty && !m.roles.any(_selectedRoles.contains)) return false;
      if (_query.isNotEmpty) {
        final haystack = '${m.fullName} ${m.email}'.toLowerCase();
        if (!haystack.contains(_query)) return false;
      }
      return true;
    }).toList();

    result.sort((a, b) => _sortMode == UserSortMode.nameDesc
        ? b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase())
        : a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

    return result;
  }

  Set<String> get _availableRoles => _members.expand((m) => m.roles).toSet();

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<UserFiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserFiltersBottomSheet(
        initialStatus: _statusFilter,
        initialRoles: _selectedRoles,
        initialSort: _sortMode,
        availableRoles: _availableRoles,
      ),
    );
    if (result == null) return;
    setState(() {
      _statusFilter = result.status;
      _selectedRoles = result.roles;
      _sortMode = result.sort;
    });
  }

  Future<void> _openInvite() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InviteUserBottomSheet(),
    );
  }

  Future<void> _openMemberDetail(TenantMember member) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailBottomSheet(member: member),
    );
  }

  Future<void> _confirmUnlink(TenantMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Desasociar usuario?'),
        content: Text('${member.fullName} dejará de pertenecer a esta organización. Su cuenta no se elimina.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Desasociar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esta función estará disponible próximamente.')),
    );
  }

  Future<void> _openPendingRequests() async {
    final tenantId = _tenantId;
    if (tenantId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PendingJoinRequestsScreen(tenantId: tenantId)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const UsersSkeletonLoader();
    if (_error != null) return _buildError(context);

    final colors = AppColors.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_pendingRequestsCount > 0) ...[
                  _PendingRequestsBanner(count: _pendingRequestsCount, colors: colors, onTap: _openPendingRequests),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar usuario...',
                          prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderPill, borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: AppRadius.borderPill, borderSide: BorderSide(color: colors.border)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: colors.surface,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd, side: BorderSide(color: colors.border)),
                      child: InkWell(
                        onTap: _openFilters,
                        borderRadius: AppRadius.borderMd,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.tune_rounded, color: colors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_members.isEmpty)
                  _EmptyMembersNotice(colors: colors, onInvite: _openInvite)
                else if (_filteredMembers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(
                      child: Text('Sin resultados para tu búsqueda.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
                    ),
                  )
                else
                  for (final member in _filteredMembers) ...[
                    UserCard(
                      member: member,
                      onTap: () => _openMemberDetail(member),
                      onRequestUnlink: () => _confirmUnlink(member),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                const SizedBox(height: 88),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = AppColors.of(context);
    final isForbidden = _error is ApiException && (_error as ApiException).statusCode == 403;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 32),
            const SizedBox(height: AppSpacing.md),
            Text(
              isForbidden
                  ? 'No tienes acceso para ver los usuarios de esta organización.'
                  : (_error is ApiException ? (_error as ApiException).message : 'Ocurrió un error inesperado.'),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            if (!isForbidden) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}

class _PendingRequestsBanner extends StatelessWidget {
  final int count;
  final AppPalette colors;
  final VoidCallback onTap;

  const _PendingRequestsBanner({required this.count, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.warning.withOpacity(0.1),
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: colors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: colors.warning, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '$count ${count == 1 ? 'solicitud pendiente' : 'solicitudes pendientes'}',
                  style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ),
              Text('Ver solicitudes', style: AppTypography.labelMedium.copyWith(color: colors.warning, fontWeight: FontWeight.w700)),
              Icon(Icons.arrow_forward_rounded, color: colors.warning, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMembersNotice extends StatelessWidget {
  final AppPalette colors;
  final VoidCallback onInvite;

  const _EmptyMembersNotice({required this.colors, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderPill),
            child: Icon(Icons.people_outline_rounded, size: 32, color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Aún no hay miembros en esta organización.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onInvite,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Invitar usuario'),
            style: FilledButton.styleFrom(backgroundColor: colors.primary),
          ),
        ],
      ),
    );
  }
}
