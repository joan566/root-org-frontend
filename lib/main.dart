import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/register_all_routes.dart';
import 'core/design_system/colors/theme_controller.dart';


void main() {
  registerAllRoutes();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text("Hola Mundo"),
        ),
      )
    );
  }
}
