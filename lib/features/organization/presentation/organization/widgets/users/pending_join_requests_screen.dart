import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/domain/entities/join_request.dart';
import 'package:savings_api_frontend/features/tenant/presentation/state/tenant_injection.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';

/// Pantalla independiente de solicitudes pendientes de ingreso (admin), ver
/// docs/01-features/organizacion.md §"Usuarios". Abierta desde el banner de
/// `UsersTab` cuando hay al menos una solicitud `PENDING`.
class PendingJoinRequestsScreen extends StatefulWidget {
  final int tenantId;

  const PendingJoinRequestsScreen({super.key, required this.tenantId});

  @override
  State<PendingJoinRequestsScreen> createState() => _PendingJoinRequestsScreenState();
}

class _PendingJoinRequestsScreenState extends State<PendingJoinRequestsScreen> {
  bool _loading = true;
  Object? _error;
  List<JoinRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final requests = await TenantInjection.getPendingJoinRequestsController().getPendingJoinRequests(widget.tenantId, token);
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

  Future<void> _resolve(JoinRequest request, {required bool approve}) async {
    final action = approve ? 'aprobar' : 'rechazar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(approve ? '¿Aprobar solicitud?' : '¿Rechazar solicitud?'),
        content: Text('Vas a $action la solicitud de ${request.requesterFullName} para unirse a ${request.tenantName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(approve ? 'Aprobar' : 'Rechazar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token = context.read<AuthProvider>().session?.token;
    if (token == null) return;

    try {
      final controller = TenantInjection.joinRequestActionsController();
      if (approve) {
        await controller.approve(widget.tenantId, request.id, token);
      } else {
        await controller.reject(widget.tenantId, request.id, token);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Solicitud aprobada.' : 'Solicitud rechazada.')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
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
        leadingWidth: 80,
        leading: const Padding(padding: EdgeInsets.only(left: 20), child: AppBackButton()),
        title: Text('Solicitudes pendientes', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(colors),
      ),
    );
  }

  Widget _buildBody(AppPalette colors) {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxl), child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          Text(
            'No se pudieron cargar las solicitudes.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: TextButton(onPressed: _load, child: const Text('Reintentar'))),
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
          Text(
            'No hay solicitudes pendientes.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      itemCount: _requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _PendingRequestCard(
          request: request,
          colors: colors,
          onApprove: () => _resolve(request, approve: true),
          onReject: () => _resolve(request, approve: false),
        );
      },
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final JoinRequest request;
  final AppPalette colors;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingRequestCard({required this.request, required this.colors, required this.onApprove, required this.onReject});

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
                    Text(request.requesterFullName, style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700)),
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
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                  ),
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
