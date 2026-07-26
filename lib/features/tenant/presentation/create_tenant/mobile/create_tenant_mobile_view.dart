import 'package:flutter/material.dart';
import '../widgets/background_abstract_design.dart';
import '../widgets/mobile_brand_header.dart';

class CreateTenantMobileView extends StatelessWidget {
  final double horizontalPadding;
  final Widget content;

  const CreateTenantMobileView({
    super.key,
    required this.horizontalPadding,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundAbstractDesign(),
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MobileBrandHeader(),
                  const SizedBox(height: 24),
                  content,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
