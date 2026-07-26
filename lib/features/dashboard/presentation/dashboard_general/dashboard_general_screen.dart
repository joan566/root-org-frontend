import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';

// Widgets refactorizados
import 'widgets/premium_gradient_header.dart';
import 'widgets/side_control_panel.dart';
import 'widgets/header_user_block.dart';
import 'widgets/main_dashboard_feed.dart';
import 'widgets/no_active_organization_card.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../tenant/presentation/select_tenant/select_tenant_screen.dart';

/// Centro de control de la organización activa (ver
/// docs/frontend-navigation-redesign.md — Fase 2). Antes `PersonalDashboardScreen`.
class DashboardGeneralScreen extends StatefulWidget {
  const DashboardGeneralScreen({super.key});

  @override
  State<DashboardGeneralScreen> createState() => _DashboardGeneralScreenState();
}

class _DashboardGeneralScreenState extends State<DashboardGeneralScreen> {
  final ValueNotifier<bool> _isScrolledPastHeader = ValueNotifier<bool>(false);

  late List<Map<String, String>> _smartRecommendations;
  bool _initializedRecommendations = false;

  @override
  void dispose() {
    _isScrolledPastHeader.dispose();
    super.dispose();
  }

  void _dismissRecommendation(String id) {
    setState(() {
      _smartRecommendations.removeWhere((item) => item['id'] == id);
    });
    HapticFeedback.mediumImpact();
  }

  void _initRecommendations(User? user) {
    if (_initializedRecommendations) return;

    final hasOrgs = user?.tenants.isNotEmpty ?? false;
    final isProfileComplete = user?.profileStatus == 'COMPLETED';

    _smartRecommendations = [
      if (!isProfileComplete)
        {
          'id': 'rec_1',
          'title': 'Incrementa la seguridad de tu cuenta',
          'desc': 'Te sugerimos completar la verificación del perfil subiendo tu identificación corporativa oficial.',
          'btnLabel': 'Completar perfil',
        },
      if (!hasOrgs)
        {
          'id': 'rec_2',
          'title': 'Centraliza toda tu administración',
          'desc': 'Agrega una organización aliada para operar con flujos cruzados de facturación.',
          'btnLabel': 'Crear organización',
        },
    ];
    _initializedRecommendations = true;
  }

  String _formatRoles(List<String> rawRoles) {
    if (rawRoles.isEmpty) return 'Ninguno';
    return rawRoles.map((rawRole) {
      switch (rawRole.toUpperCase()) {
        case 'OWNER':
          return 'Propietario';
        case 'ADMIN':
          return 'Admin';
        case 'MEMBER':
        case 'USER':
          return 'Colaborador';
        default:
          return rawRole;
      }
    }).join(', ');
  }

  void _openOrganizationSwitcher(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SelectTenantScreen(isInitialSelection: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;
    final tenantSession = context.watch<TenantSessionController>();

    final bool hasOrganizations = authProvider.session?.hasTenant ?? false;
    final tenantsList = currentUser?.tenants ?? [];
    final int totalOrgs = tenantsList.length;
    final activeTenant = tenantSession.resolveActive(tenantsList);

    final String activeRoleFormatted = _formatRoles(activeTenant?.roles ?? const []);

    _initRecommendations(currentUser);

    final isProfileComplete = currentUser?.profileStatus == 'COMPLETED';
    final bool onboardingCompleted = isProfileComplete && hasOrganizations;

    final List<Map<String, dynamic>> checklistItems = [
      {
        'text': 'Completa tu perfil público',
        'isDone': isProfileComplete,
      },
      {
        'text': 'Verifica tu correo electrónico',
        'isDone': currentUser?.status == 'VERIFIED' || currentUser?.status == 'ACTIVE',
      },
      {
        'text': 'Crea tu primera organización',
        'isDone': hasOrganizations,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            if (scrollNotification.metrics.pixels > 120) {
              if (!_isScrolledPastHeader.value) _isScrolledPastHeader.value = true;
            } else {
              if (_isScrolledPastHeader.value) _isScrolledPastHeader.value = false;
            }
          }
          return true;
        },
        child: Stack(
          children: [
            const PremiumGradientHeader(),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isScrolledPastHeader,
                      builder: (context, isScrolled, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: HeaderUserBlock(
                            isScrolledDark: isScrolled,
                            userName: currentUser?.name ?? 'Usuario',
                            activeOrganizationName: activeTenant?.tenant.name,
                            canSwitchOrganization: totalOrgs > 1,
                            onTapOrganization: () => _openOrganizationSwitcher(context),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (!hasOrganizations) {
                              return NoActiveOrganizationView(
                                onCreateOrganization: () => Navigator.pushNamed(context, AppRoutes.createTenant),
                                onJoinOrganization: () => Navigator.pushNamed(context, AppRoutes.joinTenant),
                              );
                            }

                            if (constraints.maxWidth > 900) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: MainDashboardFeed(
                                      hasOrganizations: hasOrganizations,
                                      recommendations: _smartRecommendations,
                                      onDismissRecommendation: _dismissRecommendation,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                      flex: 4,
                                      child: SideControlPanel(
                                        checklistItems: checklistItems,
                                        showChecklist: !onboardingCompleted,
                                        onToggleCheck: (index) => HapticFeedback.lightImpact(),
                                        totalOrganizations: totalOrgs,
                                        activeRole: activeRoleFormatted,
                                        activeModules: 0,
                                      )),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                MainDashboardFeed(
                                  hasOrganizations: hasOrganizations,
                                  recommendations: _smartRecommendations,
                                  onDismissRecommendation: _dismissRecommendation,
                                ),
                                const SizedBox(height: 24),
                                SideControlPanel(
                                  checklistItems: checklistItems,
                                  showChecklist: !onboardingCompleted,
                                  onToggleCheck: (index) => HapticFeedback.lightImpact(),
                                  totalOrganizations: totalOrgs,
                                  activeRole: activeRoleFormatted,
                                  activeModules: 0,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
