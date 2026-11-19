import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await widget.controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo iniciar sesión. Inténtalo nuevamente.',
            invalidCredentialsMessage:
                'Credenciales incorrectas o correo sin verificar.',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: AuthValidation.email,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Contraseña',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) => value == null || value.isEmpty
                ? 'Ingresa tu contraseña.'
                : null,
            suffixIcon: IconButton(
              tooltip: _obscurePassword
                  ? 'Mostrar contraseña'
                  : 'Ocultar contraseña',
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Iniciar sesión',
            onPressed: _isBusy ? null : _submit,
            isLoading: _isBusy,
            isExpanded: true,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/auth/register'),
            child: const Text('Crear una cuenta'),
          ),
          if (_emailController.text.trim().isNotEmpty)
            TextButton(
              onPressed: () => context.go(
                Uri(
                  path: '/auth/email-verification',
                  queryParameters: {'email': _emailController.text.trim()},
                ).toString(),
              ),
              child: const Text('Verificar mi correo'),
            ),
        ],
      ),
    );
  }
}
