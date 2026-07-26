import 'package:flutter/material.dart';
import '../widgets/register_background_decoration.dart';
import '../widgets/left_register_identity_panel.dart';

class RegisterDesktopView extends StatelessWidget {
  final double horizontalPadding;
  final Widget formCard;

  const RegisterDesktopView({
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
          child: LeftRegisterIdentityPanel(),
        ),
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              const RegisterBackgroundDecoration(),
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
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
