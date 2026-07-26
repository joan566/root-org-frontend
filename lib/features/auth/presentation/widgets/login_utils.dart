import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('o continúa con', style: TextStyle(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        Expanded(child: Divider(color: colors.border, height: 1)),
      ],
    );
  }
}

class MobileMiniBrandHeader extends StatelessWidget {
  const MobileMiniBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: colors.slateDark, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.blur_on_rounded, color: colors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text('SUMKEYA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: colors.textPrimary, letterSpacing: 1.0)),
      ],
    );
  }
}

class AbstractBackgroundDecoration extends StatelessWidget {
  const AbstractBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary.withOpacity(0.02)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}
