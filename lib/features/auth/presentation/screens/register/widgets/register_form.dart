import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/design_system/components/buttons/app_button.dart';
import '../../../../../../core/design_system/components/inputs/app_text_field.dart';
import '../../../state/auth_controller.dart';
import '../../../state/auth_error_message.dart';
import '../../../state/auth_validation.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      await widget.controller.register(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        context.go(
          Uri(
            path: '/auth/email-verification',
            queryParameters: {'email': _emailController.text.trim()},
          ).toString(),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthErrorMessage.from(
            error,
            fallback: 'No se pudo crear la cuenta. Inténtalo nuevamente.',
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
            label: 'Nombre',
            controller: _nameController,
            textInputAction: TextInputAction.next,
            maxLength: 100,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ingresa tu nombre.'
                : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            maxLength: 150,
            validator: AuthValidation.email,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Teléfono (opcional)',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 20,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Contraseña',
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
            label: 'Crear cuenta',
            onPressed: _isBusy ? null : _submit,
            isLoading: _isBusy,
            isExpanded: true,
          ),
          TextButton(
            onPressed: () => context.go('/auth/sign-in'),
            child: const Text('Ya tengo una cuenta'),
          ),
        ],
      ),
    );
  }
}
