import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/user/presentation/profile/state/update_profile_controller.dart';
import 'package:savings_api_frontend/features/user/presentation/state/users_injection.dart';

import '../../../../auth/presentation/provider/auth_provider.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../dialogs/update_profile_error_dialog.dart';

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
    final colors = AppColors.of(context);
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: colors.brightness,
              primary: colors.primary, // Color de cabecera y selección
              onPrimary: Colors.white,
              secondary: colors.primary,
              onSecondary: Colors.white,
              error: colors.error,
              onError: Colors.white,
              surface: colors.surface,
              onSurface: colors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colors.primary),
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
    final colors = AppColors.of(context);
    // Usamos MediaQuery de forma adaptativa para que el modal no sea cortado por el teclado en pantallas chicas
    final double maxModalHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: maxModalHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(10))
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
                    Text('Editar perfil de cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.4)),
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
                              side: BorderSide(color: colors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Cancelar', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
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
                              backgroundColor: colors.primary,
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
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.trim().isEmpty ? 'Este campo es mandatario' : null,
          style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w500),
          decoration: _buildInputDecoration(icon),
        ),
      ],
    );
  }

  /// Campo de selección de fecha (Read Only para forzar uso del calendario)
  Widget _buildDatePickerField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true, // Bloquea la escritura por teclado
          onTap: onTap,    // Invoca la apertura del DatePicker
          validator: (value) => value == null || value.isEmpty ? 'Por favor selecciona una fecha válida' : null,
          style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w500),
          decoration: _buildInputDecoration(icon).copyWith(
            hintText: 'DD/MM/AAAA',
            suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  /// Dropdown adaptado al diseño limpio del ecosistema SaaS para control de género
  Widget _buildDropdownField(String label, IconData icon) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
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

          style: TextStyle(
            fontSize: 14,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),

          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: colors.textSecondary,
          ),

          dropdownColor: colors.surface,
          borderRadius: BorderRadius.circular(14),
          decoration: _buildInputDecoration(icon),
        ),
      ],
    );
  }

  /// Decoración base unificada para evitar duplicar código visual
  InputDecoration _buildInputDecoration(IconData icon) {
    final colors = AppColors.of(context);

    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: colors.textSecondary),
      filled: true,
      fillColor: colors.background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.primary, width: 1.5)),
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
      showUpdateProfileErrorDialog(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

  }
}