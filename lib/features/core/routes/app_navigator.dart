import 'package:flutter/cupertino.dart';

class AppNavigator {
  const AppNavigator._();

  static Future<T?> push<T>(
      BuildContext context,
      String route, {
        Object? arguments,
      }) {
    return Navigator.pushNamed<T>(
      context,
      route,
      arguments: arguments,
    );
  }

  static Future<T?> replace<T>(
      BuildContext context,
      String route, {
        Object? arguments,
      }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      route,
      arguments: arguments,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
      BuildContext context,
      String route, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      route,
          (_) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}