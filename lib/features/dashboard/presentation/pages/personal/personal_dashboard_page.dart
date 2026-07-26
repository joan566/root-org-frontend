import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';
import 'package:savings_api_frontend/features/core/routes/app_routes.dart';

// Widgets refactorizados
import '../../widgets/personal/premium_gradient_header.dart';
import '../../widgets/personal/side_control_panel.dart';
import '../../widgets/personal/header_user_block.dart';
import '../../widgets/personal/main_dashboard_feed.dart';
import '../../widgets/no_active_organization_card.dart';

import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/presentation/provider/auth_provider.dart';

class PersonalDashboardPage extends StatefulWidget {
  const PersonalDashboardPage({super.key});

  @override
  State<PersonalDashboardPage> createState() => _PersonalDashboardPageState();
}

class _PersonalDashboardPageState extends State<PersonalDashboardPage> {
  final ValueNotifier<bool> _isScrolledPastHeader = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.session?.user;

    final bool hasOrganizations = authProvider.session?.hasTenant ?? false;
    final tenantsList = currentUser?.tenants ?? [];
    final int totalOrgs = tenantsList.length;

    final List<String> rawRoles = (hasOrganizations && tenantsList.isNotEmpty)
        ? tenantsList.first.roles
        : const [];
    final String activeRoleFormatted = _formatRoles(rawRoles);

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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildProfessionalDrawer(context, currentUser),
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
                          child: HeaderUserBlock(isScrolledDark: isScrolled),
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
                                        activeModules: 4,
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
                                  activeModules: 4,
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

  Widget _buildProfessionalDrawer(BuildContext context, User? user) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Usuario',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    user?.email ?? 'correo@enterprise.com',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                children: [
                  _drawerItem(Icons.dashboard_rounded, 'Dashboard', () => Navigator.pop(context)),
                  _drawerItem(Icons.corporate_fare_rounded, 'Organizaciones', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.tenants);
                  }),
                  _drawerItem(Icons.person_rounded, 'Mi Perfil', () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  }),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  context.read<AuthProvider>().logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary.withOpacity(0.8), size: 22),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
