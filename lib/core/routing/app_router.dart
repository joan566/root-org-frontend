import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import 'route_names.dart';

final class AppRouter {
  AppRouter({
    List<RouteBase>? routes,
    Listenable? refreshListenable,
    GoRouterRedirect? redirect,
  }) : router = GoRouter(
         initialLocation: RouteNames.home,
         routes:
             routes ??
             [
               GoRoute(
                 path: RouteNames.home,
                 builder: (context, state) =>
                     const Scaffold(body: Center(child: Text('Hola Mundo'))),
               ),
             ],
         refreshListenable: refreshListenable,
         redirect: redirect,
         errorBuilder: (context, state) => Scaffold(
           body: Center(
             child: Text('${AppConstants.appName}: página no encontrada.'),
           ),
         ),
       );

  final GoRouter router;

  void dispose() {
    router.dispose();
  }
}
