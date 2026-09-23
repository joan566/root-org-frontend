import 'package:flutter/material.dart';

/// Escala tipografica del proyecto (nomenclatura estilo Material 3),
/// formalizada a partir de las combinaciones fontSize/fontWeight mas usadas
/// en el codigo existente (ver ADR-012-plan-migracion.md, Fase 7).
///
/// Estos estilos NO fijan color (a partir de ADR-013, modo oscuro): cada
/// consumidor debe aplicar el color segun la paleta activa, ej.
/// `AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textPrimary)`.
class AppTypography {
  const AppTypography._();

  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const TextStyle labelLarge = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle bodyLarge = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
  static const TextStyle titleSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Numero principal de una tarjeta de metricas (estilo dashboard SaaS).
  static const TextStyle displayNumber = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
}
