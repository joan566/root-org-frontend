import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../../../../core/design_system/dimensions/app_radius.dart';
import '../../../../../../core/design_system/dimensions/app_spacing.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';
import '../../../widgets/auth_entry_layout.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({required this.controller, super.key});

  final AuthController controller;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  bool _obscurePassword = true;
  bool _showTagline = true;
  bool _credentialsRejected = false;
  int _shakeTrigger = 0;
  String? _feedbackMessage;
  AuthFeedbackType? _feedbackType;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _firstValidationMessage() {
    return AuthValidation.email(_emailController.text) ??
        (_passwordController.text.isEmpty ? 'Ingresa tu contraseña.' : null);
  }

  void _clearFeedback() {
    if (_feedbackMessage == null && !_credentialsRejected) return;
    setState(() {
      _feedbackMessage = null;
      _feedbackType = null;
      _credentialsRejected = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _feedbackMessage =
            _firstValidationMessage() ??
            'Revisa los datos ingresados e inténtalo nuevamente.';
        _feedbackType = AuthFeedbackType.error;
        _credentialsRejected = false;
        _shakeTrigger++;
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _feedbackMessage = null;
      _feedbackType = null;
      _credentialsRejected = false;
    });
    try {
      await widget.controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on Object catch (error) {
      if (mounted) {
        final credentialFailure =
            error is DioException && error.response?.statusCode == 401;
        setState(() {
          _feedbackMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo iniciar sesión. Inténtalo nuevamente.',
            invalidCredentialsMessage:
                'Credenciales incorrectas o correo sin verificar.',
          );
          _feedbackType = AuthFeedbackType.error;
          _credentialsRejected = credentialFailure;
          if (credentialFailure) _shakeTrigger++;
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
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
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Bienvenido de nuevo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Inicia sesión con las credenciales de tu espacio de trabajo.',
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
                  AppTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: AuthValidation.email,
                    errorText: _credentialsRejected ? '' : null,
                    enabled: !_isBusy,
                    onChanged: (_) => _clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa tu contraseña.'
                        : null,
                    errorText: _credentialsRejected ? '' : null,
                    enabled: !_isBusy,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: _isBusy
                          ? null
                          : () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                      icon: Icon(
                        _obscurePassword
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isBusy
                    ? null
                    : () => context.go('/auth/forgot-password'),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 52,
              child: AppButton(
                label: 'Iniciar sesión',
                onPressed: _isBusy ? null : _submit,
                isLoading: _isBusy,
                isExpanded: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Divider(color: colorScheme.outlineVariant, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    'O continúa con',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: colorScheme.outlineVariant, height: 1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _GoogleComingSoonButton(),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '¿No tienes una cuenta?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: _isBusy
                      ? null
                      : () => context.go('/auth/register'),
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleComingSoonButton extends StatelessWidget {
  const _GoogleComingSoonButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            Text(
              'G',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text('Continuar con Google'),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: Text(
                  'Próximamente',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
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
