import 'package:RootOrg/core/design_system/components/badges/app_status_badge.dart';
import 'package:RootOrg/core/design_system/components/buttons/app_button.dart';
import 'package:RootOrg/core/design_system/components/inputs/app_text_field.dart';
import 'package:RootOrg/core/design_system/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('button invokes its action and text field shows its label', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              AppButton(label: 'Guardar', onPressed: () => pressed = true),
              const AppTextField(
                label: 'Nombre del producto',
                initialValue: 'Café',
              ),
              const AppStatusBadge(
                label: 'Activo',
                tone: AppStatusTone.success,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(pressed, isTrue);
    expect(find.text('Nombre del producto'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
  });

  testWidgets('loading button disables its action and shows progress', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Guardar',
            onPressed: () => pressed = true,
            isLoading: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(pressed, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
