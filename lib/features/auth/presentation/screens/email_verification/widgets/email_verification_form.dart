import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';

class EmailVerificationForm extends StatefulWidget {
  const EmailVerificationForm({
    required this.controller,
    required this.email,
    super.key,
  });

  final AuthController controller;
  final String email;

  @override
  State<EmailVerificationForm> createState() => _EmailVerificationFormState();
}

class _EmailVerificationFormState extends State<EmailVerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isBusy = false;
  String? _message;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _message = null;
    });
    try {
      await widget.controller.confirmEmailVerification(
        email: widget.email,
        code: _codeController.text,
      );
      if (mounted) {
        setState(
          () => _message = 'Correo verificado. Ya puedes iniciar sesión.',
        );
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo verificar el correo.',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _message = null;
    });
    try {
      await widget.controller.resendEmailVerificationCode(widget.email);
      if (mounted) setState(() => _message = 'Enviamos un nuevo código.');
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo enviar el código.',
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
          Text('Código enviado a ${widget.email}'),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Código de verificación',
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                ? null
                : 'Ingresa el código de 6 dígitos.',
            onSubmitted: (_) => _confirm(),
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
            label: 'Verificar correo',
            onPressed: _isBusy ? null : _confirm,
            isLoading: _isBusy,
            isExpanded: true,
          ),
          TextButton(
            onPressed: _isBusy ? null : _resend,
            child: const Text('Reenviar código'),
          ),
          TextButton(
            onPressed: () => context.go('/auth/sign-in'),
            child: const Text('Ir al inicio de sesión'),
          ),
        ],
      ),
    );
  }
}
