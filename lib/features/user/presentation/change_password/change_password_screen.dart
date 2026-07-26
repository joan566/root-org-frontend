import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/user/presentation/change_password/state/change_password_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/state/users_injection.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/shared/widgets/app_back_button.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'widgets/password_header.dart';
import 'widgets/password_form_card.dart';
import 'widgets/password_field.dart';
import 'widgets/password_requirements_list.dart';
import 'widgets/primary_button.dart';

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

