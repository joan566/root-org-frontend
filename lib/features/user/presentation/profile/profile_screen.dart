import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/login/login_screen.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/session/tenant_session_controller.dart';

// Widgets refactorizados
import 'widgets/personal_info_card.dart';
import 'widgets/preferences_card.dart';
import 'widgets/profile_completion_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/security_card.dart';
import 'widgets/contact_info_card.dart';
import 'bottom_sheets/edit_profile_bottom_sheet.dart';
import 'widgets/logout_card.dart';
import 'widgets/organizations_section.dart';

import '../../../auth/domain/entities/user.dart';
import 'state/get_user_controller.dart';
import '../state/users_injection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get user {
    return context.read<AuthProvider>().session?.user;
  }

  bool loading = true;
  late final GetUserController controller;

  Future<void> _loadProfile() async {
    try {
      final auth = context.read<AuthProvider>();
      final session = auth.session!;

      final result = await controller.getUser(
        session.user.id,
        session.token,
      );

      if (!mounted) return;
      auth.updateUser(result.user);

    } catch (e) {
      debugPrint("Error cargando perfil: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    controller = UsersInjection.getUserController();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().session?.user;
    final colors = AppColors.of(context);
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: colors.primary)));
    if (user == null) return const Scaffold(body: Center(child: Text("Perfil no disponible")));

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeader(
                name: user!.name,
                lastName: user!.lastName ?? "",
                email: user!.email,
                completionPercentage: user!.profileCompletionRatio,
                onEditPressed: () => _openEditProfileModal(
                    context, user!.name, user!.lastName ?? "---",
                    user!.document ?? "---", user!.phoneNumber, user!.dateOfBirth, user!.gender ?? ""),
              ),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileCompletionCard(completionPercentage: user!.profileCompletionRatio, pendingCount: user!.missingProfileFieldsCount),
                        const SizedBox(height: 24),

                        ProfileStats(tenantCount: user!.tenants.length),
                        const SizedBox(height: 32),

                        PersonalInfoCard(
                          name: user!.name,
                          lastName: user!.lastName ?? "",
                          document: user!.document,
                          dateOfBirth: user?.dateOfBirth != null
                              ? DateFormat('yyyy-MM-dd').format(user!.dateOfBirth!)
                              : '',
                          gender: user!.gender,
                          onEdit: () => _openEditProfileModal(
                              context, user!.name, user!.lastName ?? "---",
                              user!.document ?? "---", user!.phoneNumber, user!.dateOfBirth, user!.gender ?? ""),
                        ),
                        const SizedBox(height: 24),

                        ContactInfoCard(
                          email: user!.email,
                          phone: user!.phoneNumber,
                          onEdit: () => _openEditProfileModal(
                              context, user!.name, user!.lastName ?? "---",
                              user!.document ?? "---", user!.phoneNumber, user!.dateOfBirth, user!.gender ?? ""),
                        ),
                        const SizedBox(height: 24),

                        OrganizationsSection(tenants: user!.tenants),
                        const SizedBox(height: 24),

                        const SecurityCard(),
                        const SizedBox(height: 24),

                        const RecentActivityCard(),
                        const SizedBox(height: 24),

                        const PreferencesCard(),
                        const SizedBox(height: 40),

                        LogoutCard(
                          onLogout: () async {
                            HapticFeedback.heavyImpact();
                            context.read<TenantSessionController>().clear();
                            context.read<AuthProvider>().logout();
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditProfileModal(
      BuildContext context,
      String currentName,
      String currentLastName,
      String currentDoc,
      String currentPhone,
      DateTime? dateOfBirth,
      String gender,
      ) async {
    HapticFeedback.mediumImpact();

    final updatedProfile = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileBottomSheet(
        name: currentName,
        lastName: currentLastName,
        document: currentDoc,
        phoneNumber: currentPhone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      ),
    );

    if (updatedProfile != null && mounted) {
      context.read<AuthProvider>().updateUser(updatedProfile);
    }
  }
}
