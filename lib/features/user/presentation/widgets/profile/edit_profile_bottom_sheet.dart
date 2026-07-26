import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/update_profile_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/controllers/users_injection.dart';

import '../../../../auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final String name;
  final String lastName;
  final String document;
  final String phoneNumber;
  final DateTime? dateOfBirth; // LocalDate -> DateTime
  final String gender;

  const EditProfileBottomSheet({
    required this.name,
    required this.lastName,
    required this.document,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _docController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController; // Controlador visual para la fecha

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;

  bool loading = false;
  late final UpdateProfileController _updateProfileController;

  final Map<String, String> _genderOptions = {'Masculino': 'MALE', 'Femenino': 'FEMALE', 'Otro': 'OTHER'};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _lastNameController = TextEditingController(text: widget.lastName);
    _docController = TextEditingController(text: widget.document);
    _phoneController = TextEditingController(text: widget.phoneNumber);

    _selectedDateOfBirth = widget.dateOfBirth;
    _dobController = TextEditingController(
        text: _selectedDateOfBirth != null
            ? "${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/${_selectedDateOfBirth!.year}"
            : ""
    );

    _updateProfileController = UsersInjection.updateProfileController();

    // Validar que el género inicial coincida con las opciones o dejar nulo
    _selectedGender = _genderOptions.containsKey(widget.gender) ? widget.gender : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _docController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Método encargado de desplegar el selector de fecha con estética Material Design
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Color de cabecera y selección
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery de forma adaptativa para que el modal no sea cortado por el teclado en pantallas chicas
    final double maxModalHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: maxModalHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              // El padding inferior reacciona dinámicamente a la intrusión del teclado virtual
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Editar perfil de cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.4)),
                    const SizedBox(height: 4),

                    _buildInputField('Nombre corporativo', _nameController, Icons.person_outline_rounded),
                    const SizedBox(height: 16),
                    _buildInputField('Apellidos', _lastNameController, Icons.people_outline_rounded),
                    const SizedBox(height: 16),
                    _buildInputField('Documento de identidad', _docController, Icons.fingerprint_rounded),
                    const SizedBox(height: 16),
                    _buildInputField('Teléfono de verificación', _phoneController, Icons.phone_android_rounded),
                    const SizedBox(height: 16),

                    // Nuevo Campo: Fecha de nacimiento interactiva (No manual)
                    _buildDatePickerField('Fecha de nacimiento', _dobController, Icons.calendar_today_rounded, () => _selectDateOfBirth(context)),
                    const SizedBox(height: 16),

                    // Nuevo Campo: Dropdown estilizado para Género
                    _buildDropdownField('Género', Icons.wc_rounded),

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Cancelar', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: loading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.mediumImpact();
                                _saveChanges();
                              }
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: loading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Guardar cambios',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Campo de texto regular para Strings
  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.trim().isEmpty ? 'Este campo es mandatario' : null,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: _buildInputDecoration(icon),
        ),
      ],
    );
  }

  /// Campo de selección de fecha (Read Only para forzar uso del calendario)
  Widget _buildDatePickerField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true, // Bloquea la escritura por teclado
          onTap: onTap,    // Invoca la apertura del DatePicker
          validator: (value) => value == null || value.isEmpty ? 'Por favor selecciona una fecha válida' : null,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: _buildInputDecoration(icon).copyWith(
            hintText: 'DD/MM/AAAA',
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  /// Dropdown adaptado al diseño limpio del ecosistema SaaS para control de género
  Widget _buildDropdownField(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: _genderOptions.keys.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),

          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },

          validator: (value) =>
          value == null ? 'Por favor selecciona un género' : null,

          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),

          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.textSecondary,
          ),

          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          decoration: _buildInputDecoration(icon),
        ),
      ],
    );
  }

  /// Decoración base unificada para evitar duplicar código visual
  InputDecoration _buildInputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }

  void _saveChanges() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    final auth = context.read<AuthProvider>();
    final session = auth.session!;
    final user = session.user;

    try {
      final response = await _updateProfileController.updateProfile(
          user.id,
          _nameController.text,
          _lastNameController.text,
          _docController.text,
          _phoneController.text,
          _selectedDateOfBirth!,
          _genderOptions[_selectedGender]!,
          session.token
      );

      if (!mounted) return;

      auth.updateUser(response.user);
      Navigator.pop(context, response.user);

    } catch (e) {
      debugPrint('update profile error: $e');
      HapticFeedback.vibrate();

      if (!mounted) return;
      _showErrorPortal(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

  }

  void _showErrorPortal(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Ocurrió un error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              height: 1.4,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Entendido"),
            ),
          ],
        );
      },
    );
  }
}