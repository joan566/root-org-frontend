import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/join_tenant/state/join_tenant_controller.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../state/tenant_injection.dart';
import 'widgets/join_tenant_header.dart';
import 'widgets/code_field.dart';
import 'widgets/loading_button.dart';
import 'widgets/info_card.dart';
import 'widgets/how_it_works.dart';
import 'widgets/animated_background_effects.dart';
import 'dialogs/success_dialog.dart';
import 'dialogs/error_dialog.dart';

class JoinTenantScreen extends StatefulWidget {
  const JoinTenantScreen({super.key});

  @override
  State<JoinTenantScreen> createState() => _JoinTenantScreenState();
}

class _JoinTenantScreenState extends State<JoinTenantScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool loading = false;
  late final JoinTenantController _controller;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TenantInjection.joinTenantController();
    _focusNode.requestFocus();

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeScaleAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    codeController.dispose();
    _focusNode.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _joinTenant() async {
    FocusScope.of(context).unfocus();
    final cleanCode = codeController.text.trim();

    if (cleanCode.length < 6) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() {
      loading = true;
    });

    final auth = context.read<AuthProvider>();
    final session = auth.session!;
    final user = session.user;

    try {
      final joinTenant = await _controller.joinTenant(
        user.id,
        cleanCode,
        session.token,
      );

      user.tenants?.add(joinTenant.userTenant);
      session.hasTenant = true;
      auth.refreshSession();

      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.lightImpact());

      if (!mounted) return;
      _showSuccessPortal();
    } catch (e) {
      debugPrint('Join tenant error: $e');
      HapticFeedback.vibrate();

      if (!mounted) return;
      _showErrorPortal(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
      setState(() {
        codeController.text = text;
        codeController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
      });
      HapticFeedback.lightImpact();
    }
  }

  void _showSuccessPortal() {
    final pageNavigator = Navigator.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "SuccessPortal",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, secondAnimation, child) {
        return SuccessDialog(
          animation: animation,
          onContinue: () {
            Navigator.of(dialogContext).pop();
            pageNavigator.pop();
          },
        );
      },
    );
  }

  void _showErrorPortal(String errorText) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ErrorPortal",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: ErrorDialog(errorMessage: errorText),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20, top: 4, bottom: 4),
          child: AppBackButton(),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const AnimatedBackgroundEffects(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ScaleTransition(
                      scale: _fadeScaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimationController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const JoinTenantHeader(),
                            const SizedBox(height: 36),

                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: colors.border),
                                boxShadow: colors.premiumShadow(),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CodeField(
                                      controller: codeController,
                                      focusNode: _focusNode,
                                      enabled: !loading,
                                      onPaste: _pasteFromClipboard,
                                      onChanged: (v) => setState(() {}),
                                      onSubmitted: (_) => _joinTenant(),
                                    ),
                                    const SizedBox(height: 24),
                                    LoadingButton(
                                      isLoading: loading,
                                      isValid: codeController.text.trim().length >= 6,
                                      onPressed: _joinTenant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const InfoCard(),
                            const SizedBox(height: 32),
                            const HowItWorks(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
