import 'package:RootOrg/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the configured home route', (tester) async {
    final appRouter = AppRouter();
    addTearDown(appRouter.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter.router));

    expect(find.text('Hola Mundo'), findsOneWidget);
  });
}
