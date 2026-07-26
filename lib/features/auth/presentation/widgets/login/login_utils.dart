import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}

class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('o continúa con', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}

class MobileMiniBrandHeader extends StatelessWidget {
  const MobileMiniBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.slateDark, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        const Text('SUMKEYA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1.0)),
      ],
    );
  }
}

class AbstractBackgroundDecoration extends StatelessWidget {
  const AbstractBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.02)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}
