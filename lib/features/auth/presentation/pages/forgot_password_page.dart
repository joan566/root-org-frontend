import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';
import '../controllers/auth_injection.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/login/backend_error_card.dart';
import '../widgets/login/login_utils.dart';
import 'verification_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _backendErrorMessage;

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthInjection.forgotPassword();
    _emailFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _sendCode() async {
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
      final email = _emailController.text.trim();
      await _controller.sendCode(email);

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(email: email),
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
                        const FieldLabel(label: 'Correo electrónico'),
                        const SizedBox(height: 6),
                        _buildEmailField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
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
          child: const Icon(Icons.key_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 16),
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'No te preocupes, te enviaremos un código para restablecerla.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'nombre@empresa.com',
        prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: _isLoading ? AppColors.background : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "El correo electrónico es requerido" : null,
      onFieldSubmitted: (_) => _sendCode(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _sendCode,
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
            : const Text('Enviar código', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
