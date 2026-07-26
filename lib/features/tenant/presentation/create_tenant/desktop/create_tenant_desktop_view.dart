import 'package:flutter/material.dart';
import '../widgets/background_abstract_design.dart';
import '../widgets/left_identity_workspace_panel.dart';

class CreateTenantDesktopView extends StatelessWidget {
  final double horizontalPadding;
  final Widget content;

  const CreateTenantDesktopView({
    super.key,
    required this.horizontalPadding,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 40,
          child: LeftIdentityWorkspacePanel(),
        ),
        Expanded(
          flex: 60,
          child: Stack(
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
                      children: [content],
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
