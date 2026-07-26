import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class BackgroundAbstractDesign extends StatelessWidget {
  const BackgroundAbstractDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.02)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
            ),
          ),
        ],
      ),
    );
  }
}
