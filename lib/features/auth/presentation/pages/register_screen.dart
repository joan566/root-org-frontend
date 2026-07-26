import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

import '../controllers/auth_injection.dart';
import '../controllers/register_controller.dart';

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
            return _SuccessConfirmationView(
              onActionPressed: () => Navigator.pop(context),
            );
          }

          return Row(
            children: [
              if (isDesktop)
                const Expanded(
                  flex: 45,
                  child: _LeftRegisterIdentityPanel(),
                ),

              Expanded(
                child: Stack(
                  children: [
                    const _AbstractBackgroundDecoration(),
                    Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 64.0 : (isTablet ? 48.0 : 20.0),
                          vertical: 32.0,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isDesktop) ...[
                                const _MobileMiniBrandHeader(),
                                const SizedBox(height: 32),
                              ],

                              if (_backendErrorMessage != null) ...[
                                _BackendErrorCard(
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
                                        const _FormHeader(),
                                        const SizedBox(height: 24),

                                        const _FieldLabel(label: 'Nombre completo'),
                                        const SizedBox(height: 6),
                                        _buildNameField(),
                                        const SizedBox(height: 18),

                                        const _FieldLabel(label: 'Teléfono de contacto'),
                                        const SizedBox(height: 6),
                                        _buildPhoneField(),
                                        const SizedBox(height: 18),

                                        const _FieldLabel(label: 'Correo electrónico corporativo'),
                                        const SizedBox(height: 6),
                                        _buildEmailField(),
                                        const SizedBox(height: 18),

                                        const _FieldLabel(label: 'Contraseña de seguridad'),
                                        const SizedBox(height: 6),
                                        _buildPasswordField(),
                                        const SizedBox(height: 8),
                                        _PasswordStrengthIndicator(password: _passwordController.text),
                                        const SizedBox(height: 20),

                                        _buildTermsCheckbox(),
                                        const SizedBox(height: 24),

                                        _buildSubmitButton(),
                                        const SizedBox(height: 28),

                                        const _FormDivider(),
                                        const SizedBox(height: 20),
                                        const _FutureSocialLoginsGrid(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              const _LoginRedirectBottomCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const _PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    int points = 0;
    if (password.length >= 8) points++;
    if (password.contains(RegExp(r'[A-Z]'))) points++;
    if (password.contains(RegExp(r'[0-9]'))) points++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) points++;

    Color color = AppColors.error;
    String label = 'Fuerte debilidad';
    if (points == 2) { color = Colors.orange; label = 'Aceptable'; }
    if (points == 3) { color = Colors.amber; label = 'Media-Alta'; }
    if (points == 4) { color = AppColors.primary; label = 'Altamente Segura'; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < points ? color : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        Text('Seguridad local: $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _SuccessConfirmationView extends StatelessWidget {
  final VoidCallback onActionPressed;
  const _SuccessConfirmationView({super.key, required this.onActionPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.premiumShadow(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('¡Registro exitoso!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                const Text(
                  'Tu cuenta ha sido creada correctamente en el ecosistema corporativo. Ahora puedes iniciar sesión con tus credenciales asignadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onActionPressed,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Ir al inicio de sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftRegisterIdentityPanel extends StatelessWidget {
  const _LeftRegisterIdentityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slateDark,
      child: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.02, child: CustomPaint(painter: _GridPatternPainter()))),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.12)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(54.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('SUMKEYA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Las redes unidas mantienen a todos avanzando.', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1.0, height: 1.25)),
                    const SizedBox(height: 12),
                    const Text('Una plataforma global para administrar organizaciones, equipos y módulos funcionales desde un solo lugar centralizado.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5)),
                    const SizedBox(height: 32),
                    _buildBenefitItem('Gestión multi-organización integrada'),
                    _buildBenefitItem('Arquitectura modular escalable'),
                    _buildBenefitItem('Plataforma altamente disponible'),
                    _buildBenefitItem('Seguridad empresarial punta a punta'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('¿Por qué crear una cuenta?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMiniFeatureCard('Protección', 'Datos cifrados'),
                        const SizedBox(width: 12),
                        _buildMiniFeatureCard('Colaboración', 'Flujo de equipos'),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMiniFeatureCard(String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.domain_add_rounded, color: AppColors.primary, size: 24),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border)),
              child: const Text('Paso 1 de 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text('Crear una cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        const Text('Comienza a administrar tus organizaciones de forma segura.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _BackendErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _BackendErrorCard({super.key, required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 2.0), child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error al procesar registro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF991B1B)),
            style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
    );
  }
}

class _LoginRedirectBottomCard extends StatelessWidget {
  const _LoginRedirectBottomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Ya tienes una cuenta?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('Puedes iniciar sesión en tu entorno de trabajo.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Iniciar sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          )
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}

class _FormDivider extends StatelessWidget {
  const _FormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('o regístrate con', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}

class _FutureSocialLoginsGrid extends StatelessWidget {
  const _FutureSocialLoginsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDisabledProviderButton('Google')),
        const SizedBox(width: 12),
        Expanded(child: _buildDisabledProviderButton('GitHub')),
      ],
    );
  }

  Widget _buildDisabledProviderButton(String provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(provider, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            child: const Text('Próximamente', style: TextStyle(fontSize: 7, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class _MobileMiniBrandHeader extends StatelessWidget {
  const _MobileMiniBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.slateDark, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        const Text('SUMKEYA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1.0)),
      ],
    );
  }
}

class _AbstractBackgroundDecoration extends StatelessWidget {
  const _AbstractBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.015)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.25)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    double step = 48.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
