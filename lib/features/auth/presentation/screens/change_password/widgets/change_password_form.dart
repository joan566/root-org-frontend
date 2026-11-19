import 'package:flutter/material.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({required this.controller, super.key});

  final AuthController controller;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isBusy = false;
  String? _message;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _message = null;
      _errorMessage = null;
    });
    try {
      await widget.controller.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (mounted) {
        setState(() => _message = 'Tu contraseña se actualizó correctamente.');
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo cambiar la contraseña.',
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
            label: 'Contraseña actual',
            controller: _oldPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.isEmpty
                ? 'Ingresa tu contraseña actual.'
                : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Nueva contraseña',
            controller: _newPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: AuthValidation.password,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Confirmar contraseña',
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                AuthValidation.confirmation(value, _newPasswordController.text),
            onSubmitted: (_) => _submit(),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Cambiar contraseña',
            onPressed: _isBusy ? null : _submit,
            isLoading: _isBusy,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
