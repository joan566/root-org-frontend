import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class CodeField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onPaste;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const CodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onPaste,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.trim().length;
    final bool hasInput = length > 0;
    final bool isValid = length >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CÓDIGO DE INVITACIÓN",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !widget.enabled
                  ? AppColors.border
                  : (_isFocused
                  ? (isValid ? AppColors.primary : AppColors.textPrimary)
                  : AppColors.border),
              width: _isFocused ? 1.75 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: (isValid ? AppColors.primary : AppColors.textPrimary).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          child: Center(
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
                  return newValue.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                hintText: "Código de invitación",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
                prefixIcon: const Icon(Icons.key_rounded, size: 20, color: AppColors.textSecondary),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasInput)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onChanged('');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.content_paste_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: widget.enabled ? widget.onPaste : null,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        tooltip: 'Pegar código',
                      ),
                    ],
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: !hasInput
              ? const SizedBox(height: 18)
              : (!isValid
              ? const Row(
            key: ValueKey("error_len"),
            children: [
              Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              SizedBox(width: 6),
              Text('Código demasiado corto', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
            ],
          )
              : const Row(
            key: ValueKey("ok_len"),
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text('Formato válido', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          )),
        ),
      ],
    );
  }
}
