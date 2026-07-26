import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

import '../state/auth_injection.dart';
import 'state/register_controller.dart';
import '../widgets/login_utils.dart' show FieldLabel;
import 'widgets/password_strength_indicator.dart';
import 'widgets/success_confirmation_view.dart';
import 'widgets/register_form_header.dart';
import 'widgets/register_backend_error_card.dart';
import 'widgets/login_redirect_bottom_card.dart';
import 'widgets/register_form_divider.dart';
import 'widgets/register_social_logins_grid.dart';
import 'mobile/register_mobile_view.dart';
import 'desktop/register_desktop_view.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _backendErrorMessage;

  bool _acceptTerms = false;

  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = AuthInjection.register();
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _register() async {
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
      await controller.register(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isSuccess = true;
      });
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 950;
          bool isTablet = constraints.maxWidth <= 950 && constraints.maxWidth > 600;

          if (_isSuccess) {
            return SuccessConfirmationView(
              onActionPressed: () => Navigator.pop(context),
            );
          }

          final double horizontalPadding = isDesktop ? 64.0 : (isTablet ? 48.0 : 20.0);
          final formCard = _buildFormCard();

          return isDesktop
              ? RegisterDesktopView(horizontalPadding: horizontalPadding, formCard: formCard)
              : RegisterMobileView(horizontalPadding: horizontalPadding, formCard: formCard);
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_backendErrorMessage != null) ...[
          RegisterBackendErrorCard(
            message: _backendErrorMessage!,
            onClose: () => setState(() => _backendErrorMessage = null),
          ),
          const SizedBox(height: 20),
        ],

        FocusTraversalGroup(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.premiumShadow(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegisterFormHeader(),
                  const SizedBox(height: 24),

                  const FieldLabel(label: 'Nombre completo'),
                  const SizedBox(height: 6),
                  _buildNameField(),
                  const SizedBox(height: 18),

                  const FieldLabel(label: 'Teléfono de contacto'),
                  const SizedBox(height: 6),
                  _buildPhoneField(),
                  const SizedBox(height: 18),

                  const FieldLabel(label: 'Correo electrónico corporativo'),
                  const SizedBox(height: 6),
                  _buildEmailField(),
                  const SizedBox(height: 18),

                  const FieldLabel(label: 'Contraseña de seguridad'),
                  const SizedBox(height: 6),
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  PasswordStrengthIndicator(password: _passwordController.text),
                  const SizedBox(height: 20),

                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),

                  _buildSubmitButton(),
                  const SizedBox(height: 28),

                  const RegisterFormDivider(),
                  const SizedBox(height: 20),
                  const RegisterSocialLoginsGrid(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const LoginRedirectBottomCard(),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint: 'Ej. Juan Pérez', icon: Icons.person_outline_rounded),
      validator: (v) => (v == null || v.isEmpty) ? "El nombre es requerido" : null,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint: '+1 (555) 000-0000', icon: Icons.phone_android_outlined),
      validator: (v) => (v == null || v.isEmpty) ? "El teléfono es requerido" : null,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint: 'nombre@empresa.com', icon: Icons.mail_outline_rounded),
      validator: (v) => (v == null || v.isEmpty) ? "El correo electrónico es requerido" : null,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Crea una contraseña robusta',
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
      validator: (v) => (v == null || v.isEmpty) ? "La contraseña es requerida" : null,
      onFieldSubmitted: (_) => _register(),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: _isLoading ? null : (value) => setState(() => _acceptTerms = value ?? false),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'He leído y acepto los Términos y Condiciones junto con las Políticas de Privacidad corporativas.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _register,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Creando tu cuenta...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
            ],
          )
              : const Text('Crear Cuenta Organizacional', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: _isLoading ? AppColors.background : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
    );
  }
}
