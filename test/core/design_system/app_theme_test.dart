import 'package:RootOrg/core/design_system/colors/app_colors.dart';
import 'package:RootOrg/core/design_system/colors/app_palette.dart';
import 'package:RootOrg/core/design_system/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provides distinct light and dark Material 3 themes', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppColors.light.primary, AppPalette.brandGreen);
    expect(AppColors.dark.primary, AppPalette.brandGreenLight);
  });

  test('brand foreground colors have readable contrast', () {
    expect(
      _contrastRatio(AppColors.light.primary, AppColors.light.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.light.secondary, AppColors.light.onSecondary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.dark.primary, AppColors.dark.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.dark.secondary, AppColors.dark.onSecondary),
      greaterThanOrEqualTo(4.5),
    );
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}
