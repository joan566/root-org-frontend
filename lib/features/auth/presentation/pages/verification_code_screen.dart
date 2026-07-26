import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../controllers/auth_injection.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/login/backend_error_card.dart';
import 'reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _codeFocusNode = FocusNode();

  bool _isLoading = false;
  String? _backendErrorMessage;

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthInjection.forgotPassword();
    _codeFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
      _backendErrorMessage = null;
    });

    try {
      final code = _codeController.text.trim();
      final resetToken = await _controller.verifyCode(widget.email, code);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _backendErrorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resendCode() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
      _backendErrorMessage = null;
    });

    try {
      await _controller.sendCode(widget.email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hemos reenviado el código a tu correo.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _backendErrorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_backendErrorMessage != null) ...[
                  BackendErrorCard(
                    message: _backendErrorMessage!,
                    onClose: () => setState(() => _backendErrorMessage = null),
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.premiumShadow(),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildCodeField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                        _buildResendAction(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 16),
        const Text(
          'Verifica tu correo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Hemos enviado un código a ${widget.email}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      controller: _codeController,
      focusNode: _codeFocusNode,
      enabled: !_isLoading,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '000000',
        hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5), letterSpacing: 8),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        filled: true,
        fillColor: _isLoading ? AppColors.background : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Ingresa el código" : null,
      onFieldSubmitted: (_) => _verifyCode(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _verifyCode,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Text('Verificar código', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResendAction() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _resendCode,
        child: const Text(
          '¿No recibiste el código? Reenviar',
          style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
