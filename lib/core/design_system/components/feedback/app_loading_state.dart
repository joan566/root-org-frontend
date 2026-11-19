import 'package:flutter/material.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, textAlign: TextAlign.center),
        ],
      ],
    );

    return Center(
      child: Semantics(
        label: message ?? 'Cargando',
        liveRegion: true,
        child: content,
      ),
    );
  }
}
