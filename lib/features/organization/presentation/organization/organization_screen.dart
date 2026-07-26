import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import 'package:savings_api_frontend/shared/layouts/coming_soon_screen.dart';
import 'widgets/organization_info_tab.dart';

/// Sección "Organización" del shell (ver docs/frontend-navigation-redesign.md
/// §3.1). Información es la única pestaña funcional hoy (solo lectura, con
/// datos ya disponibles en sesión); Usuarios/Roles/Estructura son
/// placeholders honestos — ninguna tiene backend todavía (`TenantApi` solo
/// expone crear/unirse; ADR-011 excluye explícitamente administración de
/// roles).
class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
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
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: colors.primary,
              labelStyle: AppTypography.labelLarge,
              tabs: const [
                Tab(text: 'Información'),
                Tab(text: 'Usuarios'),
                Tab(text: 'Roles'),
                Tab(text: 'Estructura'),
              ],
            ),
            Divider(color: colors.border, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OrganizationInfoTab(),
                  ComingSoonView(
                    title: 'Usuarios',
                    description: 'Todavía no hay un endpoint para listar los miembros de esta organización.',
                    icon: Icons.people_alt_rounded,
                  ),
                  ComingSoonView(
                    title: 'Roles',
                    description:
                        'La administración de roles (crear roles personalizados, asignar permisos) está explícitamente fuera de alcance del backend por ahora.',
                    icon: Icons.shield_outlined,
                  ),
                  ComingSoonView(
                    title: 'Estructura organizacional',
                    description: 'Todavía no existe un modelo de datos para la estructura interna de la organización.',
                    icon: Icons.account_tree_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
