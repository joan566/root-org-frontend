import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

// Widgets refactorizados
import 'package:savings_api_frontend/shared/widgets/backend_error_card.dart';
import 'package:savings_api_frontend/shared/widgets/field_label.dart';
import 'widgets/create_account_card.dart';
import 'widgets/login_form_header.dart';
import '../widgets/login_utils.dart' show FormDivider;
import 'widgets/social_logins_grid.dart';
import '../forgot_password/forgot_password_screen.dart';

// Controladores e Inyección
import '../state/auth_injection.dart';
import 'state/login_controller.dart';
import '../provider/auth_provider.dart';
import 'package:savings_api_frontend/features/tenant/presentation/my_organizations/my_organizations_screen.dart';

// Vistas responsive (Fase 5)
import 'mobile/login_mobile_view.dart';
import 'desktop/login_desktop_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _backendErrorMessage;
  bool _rememberMe = false;

  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthInjection.login();
    _emailFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
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
      final session = await _controller.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      context.read<AuthProvider>().login(session);

      // MaterialApp.home reactivo solo actualiza la pantalla mientras siga
      // en la ruta "/" del Navigator raíz; tras un logout (que ya hace
      // pushAndRemoveUntil hacia aquí) este LoginScreen ya no está en "/",
      // así que sin esta navegación explícita un segundo login se queda
      // atascado. El gate se muestra siempre tras loguearse, así que el
      // destino es siempre MyOrganizationsScreen, nunca directo al shell.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MyOrganizationsScreen()),
        (route) => false,
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
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 950;
          bool isTablet = constraints.maxWidth <= 950 && constraints.maxWidth > 600;
          final double horizontalPadding = isDesktop ? 64.0 : (isTablet ? 48.0 : 20.0);
          final formCard = _buildFormCard();

          return isDesktop
              ? LoginDesktopView(horizontalPadding: horizontalPadding, formCard: formCard)
              : LoginMobileView(horizontalPadding: horizontalPadding, formCard: formCard);
        },
      ),
    );
  }

  Widget _buildFormCard() {
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_backendErrorMessage != null) ...[
          BackendErrorCard(
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
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.border),
                boxShadow: colors.premiumShadow(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginFormHeader(),
                  const SizedBox(height: 28),

                  const FieldLabel(label: 'Correo electrónico'),
                  const SizedBox(height: 6),
                  _buildEmailField(),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FieldLabel(label: 'Contraseña'),
                      _buildForgotPasswordAction(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildPasswordField(),
                  const SizedBox(height: 16),

                  _buildRememberMeCheckbox(),
                  const SizedBox(height: 24),

                  _buildSubmitButton(),
                  const SizedBox(height: 28),

                  const FormDivider(),
                  const SizedBox(height: 20),

                  const FutureSocialLoginsGrid(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const CreateAccountBottomCard(),
      ],
    );
  }

  Widget _buildEmailField() {
    final colors = AppColors.of(context);

    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'nombre@empresa.com',
        prefixIcon: Icon(Icons.mail_outline_rounded, size: 18, color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: _isLoading ? colors.background : colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderFocus, width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "El correo electrónico es requerido" : null,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
    );
  }

  Widget _buildPasswordField() {
    final colors = AppColors.of(context);

    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: '••••••••••••',
        prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: colors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: colors.textSecondary),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          splashRadius: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: _isLoading ? colors.background : colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderFocus, width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "La contraseña es requerida" : null,
      onFieldSubmitted: (_) => _login(),
    );
  }

  Widget _buildForgotPasswordAction() {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
              );
            },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    final colors = AppColors.of(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _rememberMe,
            activeColor: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: _isLoading ? null : (value) => setState(() => _rememberMe = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Mantener sesión iniciada',
          style: TextStyle(fontSize: 13, color: colors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final colors = AppColors.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _login,
        style: FilledButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.surface,
          disabledBackgroundColor: colors.textMuted.withOpacity(0.4),
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
              Text(
                'Verificando credenciales...',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.1),
              )
            ],
          )
              : const Text(
            'Iniciar Sesión',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.1),
          ),
        ),
      ),
    );
  }
}
