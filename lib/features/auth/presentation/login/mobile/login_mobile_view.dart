import 'package:flutter/material.dart';
import '../../widgets/login_utils.dart' show AbstractBackgroundDecoration, MobileMiniBrandHeader;

class LoginMobileView extends StatelessWidget {
  final double horizontalPadding;
  final Widget formCard;

  const LoginMobileView({
    super.key,
    required this.horizontalPadding,
    required this.formCard,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
