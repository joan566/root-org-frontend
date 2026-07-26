import 'package:flutter/material.dart';

/// Registro central de rutas del navigator interno del shell, poblado por
/// cada feature (ver docs/00-core/07-refactor-arquitectura-frontend/
/// 03-arquitectura-navegacion.md §3.1). El shell no necesita conocer las
/// pantallas de cada feature: solo resuelve nombres de ruta contra este
/// registro, que cada feature completa con su propio archivo `*_routes.dart`.
class RouteRegistry {
  RouteRegistry._();

  static final RouteRegistry instance = RouteRegistry._();

  final Map<String, WidgetBuilder> _builders = {};

  void register(String routeName, WidgetBuilder builder) {
    _builders[routeName] = builder;
  }

  WidgetBuilder? resolve(String? routeName) => _builders[routeName];
}
