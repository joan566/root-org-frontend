import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';
import 'geometric_pattern_painter.dart';

class PremiumGradientHeader extends StatelessWidget {
  const PremiumGradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF2FBF7),
            Color(0xFFDDF4EC),
            Color(0xFF8FC8B2),
            Color(0xFF2A755D),
            Color(0xFF033328),
            Color(0xFF021A14),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Glow principal
          Positioned(
            top: -90,
            right: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 90,
                  sigmaY: 90,
                ),
                child: const SizedBox(),
              ),
            ),
          ),

          // Glow secundario
          Positioned(
            bottom: 60,
            left: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.45),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 70,
                  sigmaY: 70,
                ),
                child: const SizedBox(),
              ),
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: GeometricPatternPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}