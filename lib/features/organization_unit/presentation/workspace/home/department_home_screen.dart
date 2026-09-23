import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_capabilities.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/department_summary.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/organization_units_provider.dart';
import 'package:savings_api_frontend/features/organization_unit/presentation/state/workspace_lookup.dart';
import 'package:savings_api_frontend/features/permission/presentation/state/permissions_provider.dart';

/// "Centro de Trabajo" -- pantalla de entrada del Workspace de un
/// departamento. Grid de tarjetas (mismo lenguaje visual que
/// `moduleCatalog`/`ModuleSummaryCard` del Dashboard, ver
/// docs/01-features/organizacion.md §"Workspace") filtrado por
/// [DepartmentCapabilities]. Punto de extensión: cuando exista un backend de
/// activación de módulos, aquí es donde se agregarían más tarjetas
/// condicionadas a ese estado -- no se construye ninguna arquitectura de
/// catálogo/plugin todavía, solo esta lista explícita.
class DepartmentHomeScreen extends StatelessWidget {
  final int unitId;
  final void Function(String route) onOpenTool;

  const DepartmentHomeScreen({super.key, required this.unitId, required this.onOpenTool});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final activeTenant = activeUserTenant(context);
    final tenantId = activeTenant?.tenant.id;
    final currentUserId = context.read<AuthProvider>().session?.user.id;

    final summaries = tenantId == null ? const <DepartmentSummary>[] : context.watch<OrganizationUnitsProvider>().summariesFor(tenantId);
    DepartmentSummary? summary;
    for (final s in summaries) {
      if (s.unit.id == unitId) {
        summary = s;
        break;
      }
    }

    if (summary == null || tenantId == null || currentUserId == null || activeTenant == null) {
      return Center(
        child: Text('No se encontró el departamento.', style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
      );
    }

    final managerId = context.watch<OrganizationUnitsProvider>().managerFor(unitId)?.userId;
    final capabilities = DepartmentCapabilities(context.watch<PermissionsProvider>().codesForUnit(tenantId, unitId));
    final tools = <_WorkspaceTool>[
      if (capabilities.canManageMembers)
        _WorkspaceTool(
          icon: Icons.groups_outlined,
          title: 'Miembros',
          description: 'Agregar o remover integrantes del departamento.',
          colorKey: 'primary',
          route: 'members',
        ),
      if (capabilities.canManageRoles)
        _WorkspaceTool(
          icon: Icons.badge_outlined,
          title: 'Roles departamentales',
          description: 'Asignar o quitar el rol de cada miembro.',
          colorKey: 'secondary',
          route: 'roles',
        ),
      if (capabilities.canManageJoinRequests)
        _WorkspaceTool(
          icon: Icons.mark_email_unread_outlined,
          title: 'Solicitudes de ingreso',
          description: 'Aprobar o rechazar quién quiere unirse.',
          colorKey: 'warning',
          route: 'join_requests',
        ),
      _WorkspaceTool(
        icon: Icons.info_outline_rounded,
        title: 'Información',
        description: 'Datos del departamento y su encargado.',
        colorKey: 'success',
        route: 'info',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        _SummaryCard(summary: summary, hasManager: managerId != null, capabilities: capabilities, colors: colors),
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.95,
          children: [for (final tool in tools) _ToolCard(tool: tool, colors: colors, onTap: () => onOpenTool(tool.route))],
        ),
      ],
    );
  }
}

class _WorkspaceTool {
  final IconData icon;
  final String title;
  final String description;
  final String colorKey;
  final String route;

  const _WorkspaceTool({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorKey,
    required this.route,
  });
}

Color _resolveAccent(AppPalette colors, String key) {
  switch (key) {
    case 'warning':
      return colors.warning;
    case 'secondary':
      return colors.secondary;
    case 'success':
      return colors.success;
    default:
      return colors.primary;
  }
}

/// Resumen real (nombre, si tiene encargado, total de miembros) -- nunca
/// "solicitudes pendientes": mostrar un contador exigiría pedirlo aparte
/// solo para esta tarjeta (un GET que nadie más necesita en el Home), y un
/// contador fijo en 0 sería peor -- se vería como "no hay nada" aunque sí
/// las haya. El número real ya vive dentro de la propia herramienta
/// "Solicitudes de ingreso", que sí lo consulta.
class _SummaryCard extends StatelessWidget {
  final DepartmentSummary summary;
  final bool hasManager;
  final DepartmentCapabilities capabilities;
  final AppPalette colors;

  const _SummaryCard({required this.summary, required this.hasManager, required this.capabilities, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: colors.flatCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.unit.name, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasManager ? 'Encargado asignado' : 'Sin encargado asignado',
            style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _Stat(label: 'Miembros', value: '${summary.memberCount}', colors: colors),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final AppPalette colors;

  const _Stat({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: colors.textSecondary)),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _WorkspaceTool tool;
  final AppPalette colors;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = _resolveAccent(colors, tool.colorKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: onTap,
        child: Container(
          decoration: colors.flatCardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: AppRadius.borderMd),
                  child: Icon(tool.icon, color: accent, size: 22),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(tool.title, style: AppTypography.titleSmall.copyWith(color: colors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: Text(
                    tool.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
