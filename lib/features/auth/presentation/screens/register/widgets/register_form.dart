import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../../../../core/design_system/dimensions/app_spacing.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';
import '../../../widgets/auth_entry_layout.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({required this.controller, super.key});

  final AuthController controller;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isBusy = false;
  bool _showTagline = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _shakeTrigger = 0;
  String? _feedbackMessage;
  AuthFeedbackType? _feedbackType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _firstValidationMessage() {
    if (_nameController.text.trim().isEmpty) return 'Ingresa tu nombre.';
    return AuthValidation.email(_emailController.text) ??
        AuthValidation.password(_passwordController.text) ??
        AuthValidation.confirmation(
          _confirmController.text,
          _passwordController.text,
        );
  }

  void _clearFeedback() {
    if (_feedbackMessage == null) return;
    setState(() {
      _feedbackMessage = null;
      _feedbackType = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _feedbackMessage =
            _firstValidationMessage() ??
            'Revisa los datos ingresados e inténtalo nuevamente.';
        _feedbackType = AuthFeedbackType.error;
        _shakeTrigger++;
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _feedbackMessage = null;
      _feedbackType = null;
    });
    try {
      await widget.controller.register(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _feedbackMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo crear la cuenta. Inténtalo nuevamente.',
          );
          _feedbackType = AuthFeedbackType.error;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _feedbackMessage = 'Cuenta creada. Ahora confirma tu correo electrónico.';
      _feedbackType = AuthFeedbackType.success;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    context.go(
      Uri(
        path: '/auth/email-verification',
        queryParameters: {'email': _emailController.text.trim()},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && _showTagline) {
          setState(() => _showTagline = false);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthEntryHeader(
              showTagline: _showTagline,
              message: _feedbackMessage,
              feedbackType: _feedbackType,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Crea tu cuenta',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Regístrate para empezar a usar RootOrg.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthFieldShake(
              trigger: _shakeTrigger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tus datos', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Nombre',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    enabled: !_isBusy,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ingresa tu nombre.'
                        : null,
                    onChanged: (_) => _clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    maxLength: 150,
                    enabled: !_isBusy,
                    validator: AuthValidation.email,
                    onChanged: (_) => _clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Teléfono (opcional)',
                    controller: _phoneController,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 20,
                    enabled: !_isBusy,
                    onChanged: (_) => _clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Seguridad', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !_isBusy,
                    validator: AuthValidation.password,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: _isBusy
                          ? null
                          : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    onChanged: (_) => _clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirmController,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    enabled: !_isBusy,
                    validator: (value) => AuthValidation.confirmation(
                      value,
                      _passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirm
                          ? 'Mostrar confirmación'
                          : 'Ocultar confirmación',
                      onPressed: _isBusy
                          ? null
                          : () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    onChanged: (_) => _clearFeedback(),
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 52,
              child: AppButton(
                label: 'Crear cuenta',
                onPressed: _isBusy ? null : _submit,
                isLoading: _isBusy,
                isExpanded: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '¿Ya tienes una cuenta?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: _isBusy
                      ? null
                      : () => context.go('/auth/sign-in'),
                  child: const Text('Iniciar Sesion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
