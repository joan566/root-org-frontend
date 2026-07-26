import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/shared/widgets/header_clipper.dart';
import '../../../auth/domain/entities/user_tenant.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<UserTenant> _organizations = [];
  List<UserTenant> _filteredOrganizations = [];
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrganizations);
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadData() {
    final tenants = context.read<AuthProvider>().session?.user.tenants ?? [];
    setState(() {
      _organizations = List.from(tenants);
      _filteredOrganizations = List.from(tenants);
    });
  }

  void _filterOrganizations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrganizations = _organizations
          .where((org) => org.tenant.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _navigateTo(String route) async {
    await Navigator.pushNamed(context, route);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.read<AuthProvider>().session?.user.name ?? "Usuario";
    final totalOrgs = _organizations.length;
    final activeOrgs = _organizations.where((org) => org.status.toLowerCase() == 'activo' || org.status.toLowerCase() == 'activa').length;
    final primaryRole = _organizations.isNotEmpty && _organizations.first.roles.isNotEmpty
        ? _organizations.first.roles.join(', ')
        : 'Miembro';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              userName: userName,
              totalOrgs: totalOrgs,
              activeOrgs: activeOrgs,
              primaryRole: primaryRole,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0, left: 24.0, right: 24.0, bottom: 12.0),
              child: _SearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                isFocused: _isSearchFocused,
              ),
            ),
          ),

          if (_filteredOrganizations.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: _SectionTitle(
                  count: _filteredOrganizations.length,
                  isFiltered: _searchController.text.isNotEmpty,
                ),
              ),
            ),

          if (_organizations.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                onJoin: () => _navigateTo(AppRoutes.joinTenant),
                onCreate: () => _navigateTo(AppRoutes.createTenant),
              ),
            )
          else if (_filteredOrganizations.isEmpty)
            SliverToBoxAdapter(
              child: _NoResultsState(query: _searchController.text),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final org = _filteredOrganizations[index];
                    final bool isRecent = _organizations.length > 1 && index == 0 && _searchController.text.isEmpty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _OrganizationCard(
                        org: org,
                        isRecent: isRecent,
                        isOnlyOne: _organizations.length == 1,
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    );
                  },
                  childCount: _filteredOrganizations.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _FloatingActions(
        onJoin: () => _navigateTo(AppRoutes.joinTenant),
        onCreate: () => _navigateTo(AppRoutes.createTenant),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final int totalOrgs;
  final int activeOrgs;
  final String primaryRole;

  const _Header({
    required this.userName,
    required this.totalOrgs,
    required this.activeOrgs,
    required this.primaryRole,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 290 + statusBarHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hola $userName',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tus organizaciones',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona la organización con la que deseas trabajar.',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: -30,
          child: _StatsCard(
            totalOrgs: totalOrgs,
            activeOrgs: activeOrgs,
            primaryRole: primaryRole,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int totalOrgs;
  final int activeOrgs;
  final String primaryRole;

  const _StatsCard({
    required this.totalOrgs,
    required this.activeOrgs,
    required this.primaryRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.floatingShadow(),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.grid_view_rounded, 'Total Orgs', totalOrgs.toString()),
          Container(width: 1, height: 35, color: AppColors.border),
          _buildStatItem(Icons.verified_user_rounded, 'Rol Principal', primaryRole),
          Container(width: 1, height: 35, color: AppColors.border),
          _buildStatItem(Icons.check_circle_rounded, 'Activas', '$activeOrgs/$totalOrgs'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isFocused ? AppColors.floatingShadow() : AppColors.subtleShadow(),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.search, color: isFocused ? AppColors.primary : AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "Buscar por nombre u organización...",
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.clear();
              },
              child: const Icon(Icons.cancel_rounded, color: AppColors.textSecondary, size: 18),
            )
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int count;
  final bool isFiltered;

  const _SectionTitle({required this.count, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isFiltered ? 'Resultados encontrados' : 'Tus organizaciones asignadas',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        Text(
          '$count en total',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _OrganizationCard extends StatefulWidget {
  final UserTenant org;
  final bool isRecent;
  final bool isOnlyOne;
  final VoidCallback onTap;

  const _OrganizationCard({
    required this.org,
    required this.isRecent,
    required this.isOnlyOne,
    required this.onTap,
  });

  @override
  State<_OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<_OrganizationCard> {
  bool _isPressed = false;

  String _getInitials(String name) {
    if (name.isEmpty) return 'OR';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  Color _getDeterministicColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _getInitials(widget.org.tenant.name);
    final Color brandColor = _getDeterministicColor(widget.org.tenant.name);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.subtleShadow(),
            border: Border.all(
              color: widget.isRecent ? AppColors.primary.withOpacity(0.5) : AppColors.border,
              width: widget.isRecent ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: widget.onTap,
              splashColor: AppColors.primary.withOpacity(0.04),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isRecent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _TagBadge(
                          text: 'Última utilizada',
                          icon: Icons.star_rounded,
                          isPrimary: true,
                        ),
                      )
                    else if (widget.isOnlyOne)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _TagBadge(
                          text: 'Organización única',
                          icon: Icons.shield_outlined,
                          isPrimary: false,
                        ),
                      ),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: brandColor.withOpacity(0.1),
                          child: Text(
                            initials,
                            style: TextStyle(color: brandColor, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.org.tenant.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _RoleChip(roles: widget.org.roles),
                                  const SizedBox(width: 8),
                                  _StatusChip(status: widget.org.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: AppColors.border, height: 1),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              'Último acceso reciente',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Entrar', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;

  const _TagBadge({required this.text, required this.icon, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary.withOpacity(0.1) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isPrimary ? AppColors.primary : const Color(0xFF0369A1)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPrimary ? AppColors.primary : const Color(0xFF0369A1)),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final List<String> roles;
  const _RoleChip({required this.roles});

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: roles.map((role) {
        Color bg = const Color(0xFFF1F5F9);
        Color text = const Color(0xFF475569);

        switch (role.toLowerCase()) {
          case 'administrador':
            bg = const Color(0xFFE0F2FE);
            text = const Color(0xFF0369A1);
            break;
          case 'propietario':
            bg = const Color(0xFFD1FAE5);
            text = const Color(0xFF065F46);
            break;
          case 'consultor':
            bg = const Color(0xFFF3E8FF);
            text = const Color(0xFF7E22CE);
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Text(role, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        );
      }).toList(),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppColors.textSecondary;
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    if (status.toLowerCase() == 'activo' || status.toLowerCase() == 'activa') {
      dotColor = AppColors.success;
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (status.toLowerCase() == 'pendiente') {
      dotColor = AppColors.warning;
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (status.toLowerCase() == 'suspendido') {
      dotColor = AppColors.error;
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text('Sin resultados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'No encontramos ninguna organización que coincida con "$query".',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onCreate;

  const _EmptyState({required this.onJoin, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.subtleShadow()),
            child: const Icon(Icons.blur_on_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Comienza tu ecosistema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aún no perteneces a ninguna organización dentro de la plataforma SaaS. Crea un nuevo espacio de trabajo o únete a uno existente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear organización'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(220, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onJoin,
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: const Text('Unirse a una organización'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              minimumSize: const Size(220, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingActions extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onCreate;

  const _FloatingActions({required this.onJoin, required this.onCreate});

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                const Text('Configura tu espacio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4)),
                const SizedBox(height: 4),
                const Text('Elige el método de aprovisionamiento de tu espacio.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                _buildOption(context, Icons.business_rounded, AppColors.primary, 'Crear nueva organización', 'Configura la estructura para un nuevo entorno corporativo.', onCreate),
                const SizedBox(height: 12),
                _buildOption(context, Icons.vpn_key_outlined, const Color(0xFF3B82F6), 'Unirse mediante invitación', 'Introduce un token válido otorgado por tu administrador.', onJoin),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback action) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        action();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _openBottomSheet(context);
      },
      backgroundColor: AppColors.textPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
      label: const Text('Nueva organización', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
