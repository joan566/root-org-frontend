import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit_member.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';

/// Bandeja de solicitudes de ingreso de la unidad (`GET`/`approve`/`reject`,
/// endpoints 13/14/15 de `/organization-units`) -- sin UI en ningún lado
/// antes de este Workspace (no confundir con la bandeja de solicitudes de
/// TENANT que ya existe en `organization/.../widgets/users/`). Mismo patrón
/// visual que esa pantalla, sin cache propia (bandeja de bajo tráfico, se
/// recarga en cada visita + pull-to-refresh, mismo criterio que la de
/// tenant).
class DepartmentJoinRequestsScreen extends StatefulWidget {
  final int unitId;

  const DepartmentJoinRequestsScreen({super.key, required this.unitId});

  @override
  State<DepartmentJoinRequestsScreen> createState() => _DepartmentJoinRequestsScreenState();
}

class _DepartmentJoinRequestsScreenState extends State<DepartmentJoinRequestsScreen> {
  bool _loading = true;
  Object? _error;
  List<UnitJoinRequest> _requests = [];

  int? get _tenantId => activeUserTenant(context)?.tenant.id;

  String? get _token => context.read<AuthProvider>().session?.token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final tenantId = _tenantId;
    final token = _token;
    if (tenantId == null || token == null || !mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final requests = await OrganizationUnitInjection.getUnitJoinRequestsController().getRequests(widget.unitId, tenantId, token);
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _resolve(UnitJoinRequest request, {required bool approve}) async {
    final action = approve ? 'aprobar' : 'rechazar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(approve ? '¿Aprobar solicitud?' : '¿Rechazar solicitud?'),
        content: Text('Vas a $action la solicitud de ${_requesterName(request)} para unirse a este departamento.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(approve ? 'Aprobar' : 'Rechazar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final tenantId = _tenantId;
    final token = _token;
    if (tenantId == null || token == null) return;

    try {
      final controller = OrganizationUnitInjection.unitJoinRequestAdminActionsController();
      if (approve) {
        final result = await controller.approve(widget.unitId, request.id, tenantId, token);
        if (!mounted) return;
        _applyApprovedMember(tenantId, result.member);
      } else {
        await controller.reject(widget.unitId, request.id, tenantId, token);
      }
      if (!mounted) return;
      setState(() => _requests = _requests.where((r) => r.id != request.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Solicitud aprobada.' : 'Solicitud rechazada.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// El `member` que devuelve `approve` (con `id`/`joinedAt` reales del
  /// servidor, no inventados -- ver docs/01-features/organizacion.md
  /// §"Workspace") se agrega directamente al cache compartido, sin GET.
  void _applyApprovedMember(int tenantId, OrganizationUnitMember member) {
    final provider = context.read<OrganizationUnitsProvider>();
    final summaries = provider.summariesFor(tenantId);
    for (final summary in summaries) {
      if (summary.unit.id == widget.unitId) {
        final patched = summary.unit.copyWith(members: [...summary.unit.members, member]);
        provider.applyUpdate(tenantId, DepartmentSummary(unit: patched));
        return;
      }
    }
  }

  String _requesterName(UnitJoinRequest request) {
    final name = [request.requesterName, request.requesterLastName].where((s) => s != null && s.isNotEmpty).join(' ');
    return name.isEmpty ? 'este usuario' : name;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Solicitudes de ingreso', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody(colors)),
    );
  }

  Widget _buildBody(AppPalette colors) {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxl), child: CircularProgressIndicator()));
    }

    if (_error != null) {
      final isForbidden = _error is ApiException && (_error as ApiException).statusCode == 403;
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          Text(
            isForbidden ? 'No tienes acceso para ver las solicitudes de este departamento.' : 'No se pudieron cargar las solicitudes.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          if (!isForbidden) ...[
            const SizedBox(height: AppSpacing.lg),
            Center(child: TextButton(onPressed: _load, child: const Text('Reintentar'))),
          ],
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(Icons.mark_email_read_outlined, size: 40, color: colors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No hay solicitudes pendientes.', textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      itemCount: _requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _JoinRequestCard(
          request: request,
          colors: colors,
          onApprove: () => _resolve(request, approve: true),
          onReject: () => _resolve(request, approve: false),
        );
      },
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  final UnitJoinRequest request;
  final AppPalette colors;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _JoinRequestCard({required this.request, required this.colors, required this.onApprove, required this.onReject});

  String get _initial {
    final name = request.requesterName?.trim() ?? '';
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primaryLight,
                child: Text(_initial, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [request.requesterName, request.requesterLastName].where((s) => s != null && s.isNotEmpty).join(' '),
                      style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                    Text(request.requesterEmail ?? '', style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enviada el ${request.requestedAt.day.toString().padLeft(2, '0')}/${request.requestedAt.month.toString().padLeft(2, '0')}/${request.requestedAt.year}',
            style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                  ),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(backgroundColor: colors.primary, shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
                  child: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
