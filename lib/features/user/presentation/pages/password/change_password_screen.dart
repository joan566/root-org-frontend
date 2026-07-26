import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/change_password_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/users_injection.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/widgets/app_back_button.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  late final ChangePasswordController _changePasswordController;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePasswordRequirements);
    _changePasswordController = UsersInjection.changePasswordController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final allRequirementsMet = _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
    if (!allRequirementsMet) {
      setState(() {
        _errorMessage = "La nueva contraseña no cumple con todos los requisitos de seguridad.";
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Las contraseñas no coinciden.";
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final session = auth.session!;

    setState(() => _isLoading = true);

    try {
      final response = await _changePasswordController.changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
          _confirmPasswordController.text,
          session.token
      );

      if (!response.successfully) {
        setState(() {
          _errorMessage = response.message;
        });
      } else {
        setState(() {
          _successMessage = response.message;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _validatePasswordRequirements() {
    final val = _newPasswordController.text;
    setState(() {
      _hasMinLength = val.length >= 8;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasLowercase = val.contains(RegExp(r'[a-z]'));
      _hasNumber = val.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
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

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 640;

            return Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 40,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 540 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PasswordHeader(isDesktop: isDesktop),
                      const SizedBox(height: 32),

                      if (_errorMessage != null) ...[
                        _buildStatusBanner(_errorMessage!, AppColors.error, Icons.error_outline),
                        const SizedBox(height: 16),
                      ],
                      if (_successMessage != null) ...[
                        _buildStatusBanner(_successMessage!, AppColors.success, Icons.check_circle_outline),
                        const SizedBox(height: 16),
                      ],

                      PasswordFormCard(
                        formKey: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PasswordField(
                              label: "Contraseña actual",
                              placeholder: "Ingresa tu contraseña actual",
                              controller: _currentPasswordController,
                              prefixIcon: Icons.lock_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu contraseña actual";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            PasswordField(
                              label: "Nueva contraseña",
                              placeholder: "Ingresa tu nueva contraseña",
                              controller: _newPasswordController,
                              prefixIcon: Icons.shield_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu nueva contraseña";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            PasswordRequirementsList(
                              requirements: {
                                "8 caracteres mínimo": _hasMinLength,
                                "Una letra mayúscula": _hasUppercase,
                                "Una letra minúscula": _hasLowercase,
                                "Un número": _hasNumber,
                                "Un carácter especial": _hasSpecialChar,
                              },
                            ),
                            const SizedBox(height: 20),
                            PasswordField(
                              label: "Confirmar nueva contraseña",
                              placeholder: "Repite tu nueva contraseña",
                              controller: _confirmPasswordController,
                              prefixIcon: Icons.lock_reset_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor confirma tu contraseña";
                                }
                                if (value != _newPasswordController.text) {
                                  return "Las contraseñas no coinciden";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            PrimaryButton(
                              text: "Actualizar contraseña",
                              isLoading: _isLoading,
                              onPressed: _handleSubmit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordHeader extends StatelessWidget {
  final bool isDesktop;
  const PasswordHeader({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final double iconSize = isDesktop ? 72 : 56;

    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            color: AppColors.primary,
            size: iconSize * 0.5,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Cambiar contraseña",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const Text(
            "Actualiza tu contraseña para mantener tu cuenta protegida. Asegúrate de utilizar una contraseña segura y fácil de recordar.",
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

class PasswordFormCard extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState> formKey;

  const PasswordFormCard({
    super.key,
    required this.child,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow(),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: child,
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.prefixIcon,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: Icon(widget.prefixIcon, color: AppColors.textSecondary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2.0),
            ),
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class PasswordRequirementsList extends StatelessWidget {
  final Map<String, bool> requirements;

  const PasswordRequirementsList({super.key, required this.requirements});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tu nueva contraseña debe contener:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...requirements.entries.map((entry) {
            final isMet = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    color: isMet ? AppColors.success : AppColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
