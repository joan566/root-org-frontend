import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFFD1FAE5);
  
  // Neutral Colors
  static const Color slateDark = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate Dark for contrast
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF3B82F6);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);

  // Shadows
  static List<BoxShadow> premiumShadow() => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.02),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> subtleShadow() => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.03),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.01),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatingShadow() => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration translucentCardDecoration({double radius = 24.0}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1.5),
      boxShadow: subtleShadow(),
      gradient: LinearGradient(
        colors: [surface, background.withOpacity(0.4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }
}
