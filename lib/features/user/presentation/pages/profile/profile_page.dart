import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

// Widgets refactorizados
import '../../widgets/profile/personal_info_card.dart';
import '../../widgets/profile/preferences_card.dart';
import '../../widgets/profile/profile_completion_card.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_stats.dart';
import '../../widgets/profile/recent_activity_card.dart';
import '../../widgets/profile/security_card.dart';
import '../../widgets/profile/contact_info_card.dart';
import '../../widgets/profile/edit_profile_bottom_sheet.dart';
import '../../widgets/profile/logout_card.dart';
import '../../widgets/profile/organizations_section.dart';

import '../../../../auth/domain/entities/user.dart';
import '../../controllers/get_user_controller.dart';
import '../../controllers/users_injection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  double _getProfileProgress() {
    if (user == null) return 0.0;
    int filled = 0;
    if (user!.name.isNotEmpty) filled++;
    if (user!.lastName != null && user!.lastName!.isNotEmpty) filled++;
    if (user!.document != null && user!.document!.isNotEmpty) filled++;
    if (user!.phoneNumber.isNotEmpty) filled++;
    if (user!.dateOfBirth != null) filled++;
    if (user!.gender != null) filled++;
    return filled / 6;
  }

  int _getPendingCount() {
    if (user == null) return 6;
    int pending = 0;
    if (user!.name.isEmpty) pending++;
    if (user!.lastName == null || user!.lastName!.isEmpty) pending++;
    if (user!.document == null || user!.document!.isEmpty) pending++;
    if (user!.phoneNumber.isEmpty) pending++;
    if (user!.dateOfBirth == null) pending++;
    if (user!.gender == null || user!.gender!.isEmpty) pending++;
    return pending;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().session?.user;
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (user == null) return const Scaffold(body: Center(child: Text("Perfil no disponible")));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeader(
                name: user!.name,
                lastName: user!.lastName ?? "",
                email: user!.email,
                completionPercentage: _getProfileProgress(),
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
                        ProfileCompletionCard(completionPercentage: _getProfileProgress(), pendingCount: _getPendingCount()),
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
                            context.read<AuthProvider>().logout();
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
