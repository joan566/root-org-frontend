import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.onChanged,
    super.key,
    this.controller,
    this.hintText = 'Buscar',
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
