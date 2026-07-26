import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class RegisterBackgroundDecoration extends StatelessWidget {
  const RegisterBackgroundDecoration({super.key});

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
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary.withOpacity(0.015)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}
