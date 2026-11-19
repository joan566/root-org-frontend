import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({
    required this.controller,
    required this.resetToken,
    super.key,
  });

  final AuthController controller;
  final String resetToken;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isBusy = false;
  bool _completed = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await widget.controller.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      if (mounted) setState(() => _completed = true);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo restablecer la contraseña.',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tu contraseña se actualizó correctamente.'),
          const SizedBox(height: 16),
          AppButton(
            label: 'Ir a iniciar sesión',
            onPressed: () => context.go('/auth/sign-in'),
            isExpanded: true,
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
            label: 'Nueva contraseña',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: AuthValidation.password,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Confirmar contraseña',
            controller: _confirmController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                AuthValidation.confirmation(value, _passwordController.text),
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
            label: 'Restablecer contraseña',
            onPressed: _isBusy ? null : _submit,
            isLoading: _isBusy,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
