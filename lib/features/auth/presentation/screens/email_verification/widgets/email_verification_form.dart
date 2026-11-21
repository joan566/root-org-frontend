import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
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
  final _digitControllers = List.generate(6, (_) => TextEditingController());
  final _digitFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isBusy = false;
  String _code = '';

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final focusNode in _digitFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isBusy = true);
    try {
      await widget.controller.confirmEmailVerification(
        email: widget.email,
        code: _code,
      );
      if (!mounted) return;
      final canContinueHome =
          widget.controller.isAuthenticated &&
          widget.controller.session?.user.emailVerified == true;
      await _showResultDialog(
        title: '¡Correo verificado!',
        message:
            'Tu dirección de correo ya está confirmada. '
            'Gracias por completar este paso.',
        isSuccess: true,
        buttonLabel: canContinueHome
            ? 'Ir a la página principal'
            : 'Volver al inicio de sesión',
        onPressed: () {
          if (!mounted) return;
          if (canContinueHome) {
            widget.controller.continueAfterEmailVerification();
          } else {
            context.go('/auth/sign-in');
          }
        },
      );
    } on Object catch (error) {
      if (!mounted) return;
      await _showResultDialog(
        title: 'No se pudo verificar el correo',
        message: AuthErrorMessage.from(
          error,
          fallback: 'No se pudo verificar el correo. Inténtalo nuevamente.',
        ),
        buttonLabel: 'Entendido',
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isBusy = true);
    try {
      await widget.controller.resendEmailVerificationCode(widget.email);
      if (!mounted) return;
      await _showResultDialog(
        title: 'Código enviado',
        message: 'Enviamos un nuevo código a ${widget.email}.',
        isSuccess: true,
        buttonLabel: 'Entendido',
      );
    } on Object catch (error) {
      if (!mounted) return;
      await _showResultDialog(
        title: 'No se pudo enviar el código',
        message: AuthErrorMessage.from(
          error,
          fallback: 'No se pudo enviar el código. Inténtalo nuevamente.',
        ),
        buttonLabel: 'Entendido',
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _returnToSignIn() async {
    setState(() => _isBusy = true);
    var signOutFailed = false;
    if (widget.controller.isAuthenticated) {
      try {
        await widget.controller.signOut();
      } on Object {
        signOutFailed = true;
      }
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isBusy = false);
    context.go('/auth/sign-in');
    if (signOutFailed) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'La sesión local se cerró, pero no se pudo confirmar el cierre '
            'en el servidor.',
          ),
        ),
      );
    }
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    required String buttonLabel,
    bool isSuccess = false,
    VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isSuccess
        ? colorScheme.primary
        : colorScheme.onErrorContainer;
    final iconBackground = isSuccess
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: DecoratedBox(
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              isSuccess
                  ? Icons.mark_email_read_outlined
                  : Icons.error_outline_rounded,
              color: iconColor,
              size: 32,
            ),
          ),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          AppButton(
            label: buttonLabel,
            isExpanded: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onPressed?.call();
            },
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _updateDigit(FormFieldState<String> field, int index, String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final values = _digitControllers
        .map((controller) => controller.text)
        .toList();

    if (digits.length > 1) {
      for (
        var offset = 0;
        offset < digits.length && index + offset < 6;
        offset++
      ) {
        values[index + offset] = digits[offset];
      }
    } else {
      values[index] = digits;
    }

    for (var digitIndex = 0; digitIndex < values.length; digitIndex++) {
      _digitControllers[digitIndex].value = TextEditingValue(
        text: values[digitIndex],
        selection: TextSelection.collapsed(offset: values[digitIndex].length),
      );
    }

    _code = values.join();
    field.didChange(_code);

    if (digits.isNotEmpty) {
      final nextIndex = (index + digits.length).clamp(0, 5);
      _digitFocusNodes[nextIndex].requestFocus();
    } else if (index > 0) {
      _digitFocusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isBusy ? null : _returnToSignIn,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al inicio de sesión'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Código enviado a ${widget.email}'),
          const SizedBox(height: 16),
          FormField<String>(
            initialValue: '',
            validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                ? null
                : 'Ingresa el código de 6 dígitos.',
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: List.generate(
                    6,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                        child: TextField(
                          controller: _digitControllers[index],
                          focusNode: _digitFocusNodes[index],
                          enabled: !_isBusy,
                          autofocus: index == 0,
                          keyboardType: TextInputType.number,
                          textInputAction: index == 5
                              ? TextInputAction.done
                              : TextInputAction.next,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                          decoration: InputDecoration(
                            counterText: '',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) =>
                              _updateDigit(field, index, value),
                          onSubmitted: (_) {
                            if (index == 5) {
                              _confirm();
                            } else {
                              _digitFocusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (field.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
        ],
      ),
    );
  }
}
