import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../state/auth_injection.dart';
import '../state/forgot_password_controller.dart';
import '../widgets/backend_error_card.dart';
import '../widgets/login_utils.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _backendErrorMessage;

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthInjection.forgotPassword();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
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
      await _controller.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña restablecida con éxito. Ahora puedes iniciar sesión.'),
          backgroundColor: AppColors.success,
        ),
      );

      // Regresar al login y limpiar el stack
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                        
                        const FieldLabel(label: 'Nueva contraseña'),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _passwordController,
                          hint: '••••••••',
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const FieldLabel(label: 'Confirmar contraseña'),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: '••••••••',
                          isConfirm: true,
                        ),
                        
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
          child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nueva contraseña',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elige una contraseña segura que no hayas usado antes.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          splashRadius: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: _isLoading ? AppColors.background : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Este campo es requerido";
        if (isConfirm && v != _passwordController.text) return "Las contraseñas no coinciden";
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _resetPassword,
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
            : const Text('Restablecer contraseña', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
