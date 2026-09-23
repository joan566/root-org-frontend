import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/organization_unit.dart';
import 'package:savings_api_frontend/features/organization_unit/domain/entities/unit_join_request.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/member_unit_relation.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/my_unit_join_requests_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_unit_injection.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/tenant_member.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';

import 'package:savings_api_frontend/shared/widgets/user_detail_bottom_sheet.dart';
import 'member_relation_status_chip.dart';

/// Detalle de un departamento en la vista Member -- solo lectura salvo por
/// el ciclo de vida de la propia solicitud de ingreso (solicitar/cancelar).
/// Sin sección de miembros ni de configuración: eso es exclusivo del Admin
/// (`widgets/structure/unit_detail_screen.dart`), que además hornea sus
/// acciones de mutación directamente en los widgets sin toggle de solo
/// lectura, por eso esta pantalla es paralela y no una versión reutilizada.
class MemberUnitDetailScreen extends StatefulWidget {
  final OrganizationUnit unit;
  final Map<int, TenantMember> usersById;

  const MemberUnitDetailScreen({super.key, required this.unit, required this.usersById});

  @override
  State<MemberUnitDetailScreen> createState() => _MemberUnitDetailScreenState();
}

class _MemberUnitDetailScreenState extends State<MemberUnitDetailScreen> {
  late OrganizationUnit _unit;
  bool _loading = false;
  bool _actionBusy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureManagerLoaded());
  }

  String? get _token => context.read<AuthProvider>().session?.token;

  int? get _currentUserId => context.read<AuthProvider>().session?.user.id;

  /// ADR-021: el encargado ya no viene embebido en la unidad -- se carga
  /// aparte (`GET /organization-units/{id}/manager`).
  Future<void> _ensureManagerLoaded() async {
    final provider = context.read<OrganizationUnitsProvider>();
    if (provider.isManagerLoaded(_unit.id)) return;
    final token = _token;
    if (token == null) return;
    try {
      await provider.loadManager(_unit.id, _unit.tenantId, token);
    } catch (_) {
      // Silencioso -- la sección "Encargado" simplemente no se resuelve.
    }
  }

  /// Único punto que sí consulta el backend en esta pantalla -- solo se
  /// llama desde el pull-to-refresh y el botón "Reintentar". No existe
  /// `GET /organization-units/{id}`, así que refresca la lista completa y se
  /// queda con la unidad que coincide por `id` (igual que la versión Admin).
  Future<void> _load() async {
    final token = _token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final units = await OrganizationUnitInjection.getOrganizationUnitsController().getUnits(_unit.tenantId, token);
      final matches = units.where((u) => u.id == _unit.id);
      if (!mounted) return;
      setState(() {
        _unit = matches.isEmpty ? _unit : matches.first;
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

  MemberUnitRelation _relation(List<UnitJoinRequest> myRequests) {
    final latestByUnit = MemberUnitRelation.latestRequestByUnit(myRequests);
    return MemberUnitRelation.resolve(
      unit: _unit,
      currentUserId: _currentUserId ?? -1,
      latestRequestForUnit: latestByUnit[_unit.id],
    );
  }

  Future<void> _requestToJoin() async {
    final token = _token;
    if (token == null) return;

    setState(() => _actionBusy = true);
    try {
      final result = await OrganizationUnitInjection.requestToJoinUnitController().requestToJoin(_unit.id, token);
      if (!mounted) return;
      context.read<MyUnitJoinRequestsProvider>().applyResult(result.request);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _cancelRequest(int requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar solicitud?'),
        content: Text('Tu solicitud para unirte a "${_unit.name}" se cancelará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Volver')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancelar solicitud')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token = _token;
    if (token == null) return;

    setState(() => _actionBusy = true);
    try {
      final updated = await OrganizationUnitInjection.cancelUnitJoinRequestController().cancel(requestId, token);
      if (!mounted) return;
      context.read<MyUnitJoinRequestsProvider>().applyResult(updated);
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  void _showError(Object e) {
    final message = e is ApiException ? e.message : 'Ocurrió un error inesperado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _viewProfile(TenantMember member) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailBottomSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final myRequests = context.watch<MyUnitJoinRequestsProvider>().requests;
    final relation = _relation(myRequests);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: const Padding(padding: EdgeInsets.only(left: 20), child: AppBackButton()),
        title: Text(_unit.name, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(colors)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    children: [
                      _buildInfoSection(colors),
                      const SizedBox(height: AppSpacing.lg),
                      _buildManagerSection(colors),
                      const SizedBox(height: AppSpacing.lg),
                      _buildMembershipSection(colors, relation),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(AppPalette colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 32),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error is ApiException ? (_error as ApiException).message : 'Ocurrió un error inesperado.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppPalette colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine(label: 'Descripción', value: _unit.description.isEmpty ? 'Sin descripción registrada' : _unit.description, colors: colors),
          _InfoLine(
            label: 'Miembros',
            value: '${_unit.members.where((m) => m.isActive).length}',
            colors: colors,
          ),
          _InfoLine(
            label: 'Creado el',
            value: '${_unit.createdAt.day.toString().padLeft(2, '0')}/${_unit.createdAt.month.toString().padLeft(2, '0')}/${_unit.createdAt.year}',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildManagerSection(AppPalette colors) {
    final managerId = context.watch<OrganizationUnitsProvider>().managerFor(_unit.id)?.userId;

    final manager = managerId != null ? widget.usersById[managerId] : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Encargado', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          if (manager == null)
            Text('Sin encargado asignado.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary))
          else
            InkWell(
              onTap: () => _viewProfile(manager),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primary.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(manager.fullName, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                        Text('Encargado del departamento', style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembershipSection(AppPalette colors, MemberUnitRelation relation) {
    final (title, message, buttonLabel, onPressed) = switch (relation.status) {
      MemberUnitRelationStatus.member => ('Miembro activo', null, null, null),
      MemberUnitRelationStatus.notMember => (
          'No perteneces a este departamento.',
          null,
          'Solicitar ingreso',
          _requestToJoin,
        ),
      MemberUnitRelationStatus.pending => (
          'Solicitud enviada',
          'Estamos esperando la respuesta del encargado del departamento.',
          'Cancelar solicitud',
          () => _cancelRequest(relation.latestRequest!.id),
        ),
      MemberUnitRelationStatus.rejected => (
          'Solicitud rechazada',
          'Puedes volver a intentarlo más adelante.',
          'Solicitar nuevamente',
          _requestToJoin,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Estado', style: AppTypography.titleSmall.copyWith(color: colors.textPrimary))),
              MemberRelationStatusChip(status: relation.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _actionBusy ? null : onPressed,
                style: FilledButton.styleFrom(backgroundColor: colors.primary),
                child: _actionBusy
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(buttonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final AppPalette colors;

  const _InfoLine({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary))),
          Expanded(child: Text(value, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
