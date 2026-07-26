import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/core/routing/app_routes.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../../../auth/domain/entities/user_tenant.dart';
import 'widgets/tenant_header.dart';
import 'widgets/tenant_search_bar.dart';
import 'widgets/section_title.dart';
import 'widgets/organization_card.dart';
import 'widgets/no_results_state.dart';
import 'widgets/tenant_empty_state.dart';
import 'widgets/tenant_floating_actions.dart';

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
      backgroundColor: AppColors.of(context).background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: TenantHeader(
              userName: userName,
              totalOrgs: totalOrgs,
              activeOrgs: activeOrgs,
              primaryRole: primaryRole,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0, left: 24.0, right: 24.0, bottom: 12.0),
              child: TenantSearchBar(
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
                child: SectionTitle(
                  count: _filteredOrganizations.length,
                  isFiltered: _searchController.text.isNotEmpty,
                ),
              ),
            ),

          if (_organizations.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: TenantEmptyState(
                onJoin: () => _navigateTo(AppRoutes.joinTenant),
                onCreate: () => _navigateTo(AppRoutes.createTenant),
              ),
            )
          else if (_filteredOrganizations.isEmpty)
            SliverToBoxAdapter(
              child: NoResultsState(query: _searchController.text),
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
                      child: OrganizationCard(
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
      floatingActionButton: TenantFloatingActions(
        onJoin: () => _navigateTo(AppRoutes.joinTenant),
        onCreate: () => _navigateTo(AppRoutes.createTenant),
      ),
    );
  }
}
