import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings_api_frontend/features/shell/presentation/pages/main_layout.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/core/routes/app_routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: auth.isLogged
              ? const MainLayout()
              : const LoginPage(),
          routes: {
            AppRoutes.register: (_) => const RegisterPage(),
          },
        );
      },
    );
  }
}
