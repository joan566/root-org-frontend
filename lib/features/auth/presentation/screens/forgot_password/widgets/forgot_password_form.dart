import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({required this.controller, super.key});

  final AuthController controller;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isBusy = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await widget.controller.requestPasswordReset(_emailController.text);
      if (mounted) setState(() => _submitted = true);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo solicitar la recuperación.',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Si el correo está registrado, recibirás un enlace para restablecer '
            'tu contraseña. El enlace vence en 10 minutos.',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/auth/sign-in'),
            child: const Text('Volver a iniciar sesión'),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: AuthValidation.email,
            onSubmitted: (_) => _submit(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Enviar enlace',
            onPressed: _isBusy ? null : _submit,
            isLoading: _isBusy,
            isExpanded: true,
          ),
          TextButton(
            onPressed: () => context.go('/auth/sign-in'),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
