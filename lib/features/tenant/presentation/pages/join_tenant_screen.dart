import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/controller/join_tenant_controller.dart';
import 'package:savings_api_frontend/features/shell/presentation/widgets/app_back_button.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';
import '../controller/tenant_injection.dart';

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
        return _SuccessDialog(
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
            child: _ErrorDialog(errorMessage: errorText),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

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
            const _AnimatedBackgroundEffects(),
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
                            const _Header(),
                            const SizedBox(height: 36),

                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppColors.premiumShadow(),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _CodeField(
                                      controller: codeController,
                                      focusNode: _focusNode,
                                      enabled: !loading,
                                      onPaste: _pasteFromClipboard,
                                      onChanged: (v) => setState(() {}),
                                      onSubmitted: (_) => _joinTenant(),
                                    ),
                                    const SizedBox(height: 24),
                                    _LoadingButton(
                                      isLoading: loading,
                                      isValid: codeController.text.trim().length >= 6,
                                      onPressed: _joinTenant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const _InfoCard(),
                            const SizedBox(height: 32),
                            const _HowItWorks(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.groups_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Unirse a una organización",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.75,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Introduce el código proporcionado por tu fondo de ahorro para vincularte de forma inmediata y comenzar a colaborar.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onPaste;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onPaste,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<_CodeField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.trim().length;
    final bool hasInput = length > 0;
    final bool isValid = length >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CÓDIGO DE INVITACIÓN",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !widget.enabled
                  ? AppColors.border
                  : (_isFocused
                  ? (isValid ? AppColors.primary : AppColors.textPrimary)
                  : AppColors.border),
              width: _isFocused ? 1.75 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: (isValid ? AppColors.primary : AppColors.textPrimary).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          child: Center(
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
                  return newValue.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                hintText: "Código de invitación",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
                prefixIcon: const Icon(Icons.key_rounded, size: 20, color: AppColors.textSecondary),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasInput)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onChanged('');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.content_paste_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: widget.enabled ? widget.onPaste : null,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        tooltip: 'Pegar código',
                      ),
                    ],
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: !hasInput
              ? const SizedBox(height: 18)
              : (!isValid
              ? const Row(
            key: ValueKey("error_len"),
            children: [
              Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              SizedBox(width: 6),
              Text('Código demasiado corto', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
            ],
          )
              : const Row(
            key: ValueKey("ok_len"),
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text('Formato válido', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          )),
        ),
      ],
    );
  }
}

class _LoadingButton extends StatelessWidget {
  final bool isLoading;
  final bool isValid;
  final VoidCallback onPressed;

  const _LoadingButton({
    required this.isLoading,
    required this.isValid,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: (isLoading || !isValid) ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Validando vinculación...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
            ],
          )
              : const Text('Unirme a la organización', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿No tienes un código?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Solicítalo al administrador de la organización. Cada código identifica de forma única la organización a la que deseas pertenecer.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿CÓMO FUNCIONA?',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 18),
        _buildStep('1', 'Solicita el código al administrador.'),
        _buildStep('2', 'Ingresa el código en esta pantalla.'),
        _buildStep('3', 'Comienza a trabajar dentro de la organización.', isLast: true),
      ],
    );
  }

  Widget _buildStep(String stepNum, String text, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                child: Center(
                  child: Text(stepNum, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 16.0),
            child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          )
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onContinue;

  const _SuccessDialog({required this.animation, required this.onContinue});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _iconController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: widget.animation, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: widget.animation,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              const Text('¡Bienvenido!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Ahora haces parte de la organización.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: widget.onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  final String errorMessage;
  const _ErrorDialog({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 36),
          ),
          const SizedBox(height: 20),
          const Text('Error de vinculación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.4)),
          const SizedBox(height: 10),
          Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Entendido', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          )
        ],
      ),
    );
  }
}

class _AnimatedBackgroundEffects extends StatelessWidget {
  const _AnimatedBackgroundEffects();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ExcludeSemantics(
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.025)),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
