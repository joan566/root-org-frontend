import 'package:flutter/material.dart';
import '../../widgets/login_utils.dart' show AbstractBackgroundDecoration;
import '../widgets/left_identity_panel.dart';

class LoginDesktopView extends StatelessWidget {
  final double horizontalPadding;
  final Widget formCard;

  const LoginDesktopView({
    super.key,
    required this.horizontalPadding,
    required this.formCard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 45,
          child: LeftIdentityPanel(),
        ),
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              const AbstractBackgroundDecoration(),
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [formCard],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
