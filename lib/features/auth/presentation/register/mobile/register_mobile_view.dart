import 'package:flutter/material.dart';
import '../../widgets/login_utils.dart' show MobileMiniBrandHeader;
import '../widgets/register_background_decoration.dart';

class RegisterMobileView extends StatelessWidget {
  final double horizontalPadding;
  final Widget formCard;

  const RegisterMobileView({
    super.key,
    required this.horizontalPadding,
    required this.formCard,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                children: [
                  const MobileMiniBrandHeader(),
                  const SizedBox(height: 32),
                  formCard,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
