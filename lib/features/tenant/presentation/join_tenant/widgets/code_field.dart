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
    final colors = AppColors.of(context);
    final length = widget.controller.text.trim().length;
    final bool hasInput = length > 0;
    final bool isValid = length >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CÓDIGO DE INVITACIÓN",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: widget.enabled ? colors.surface : colors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: !widget.enabled
                  ? colors.border
                  : (_isFocused
                  ? (isValid ? colors.primary : colors.textPrimary)
                  : colors.border),
              width: _isFocused ? 1.75 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: (isValid ? colors.primary : colors.textPrimary).withOpacity(0.04),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
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
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
                prefixIcon: Icon(Icons.key_rounded, size: 20, color: colors.textSecondary),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasInput)
                        IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: colors.textMuted),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onChanged('');
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.content_paste_rounded, size: 18, color: colors.textSecondary),
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
              ? Row(
            key: const ValueKey("error_len"),
            children: [
              Icon(Icons.error_outline_rounded, size: 14, color: colors.error),
              const SizedBox(width: 6),
              Text('Código demasiado corto', style: TextStyle(fontSize: 12, color: colors.error, fontWeight: FontWeight.w500)),
            ],
          )
              : Row(
            key: const ValueKey("ok_len"),
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Text('Formato válido', style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.w600)),
            ],
          )),
        ),
      ],
    );
  }
}
