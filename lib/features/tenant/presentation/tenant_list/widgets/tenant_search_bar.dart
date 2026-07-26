import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class TenantSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  const TenantSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isFocused ? colors.floatingShadow() : colors.subtleShadow(),
        border: Border.all(
          color: isFocused ? colors.primary : colors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.search, color: isFocused ? colors.primary : colors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Buscar por nombre u organización...",
                hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.clear();
              },
              child: Icon(Icons.cancel_rounded, color: colors.textSecondary, size: 18),
            )
        ],
      ),
    );
  }
}
