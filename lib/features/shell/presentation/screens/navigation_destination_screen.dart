import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationDestinationScreen extends StatelessWidget {
  const NavigationDestinationScreen({
    required this.title,
    this.links = const [],
    super.key,
  });

  final String title;
  final List<NavigationLink> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        for (final link in links)
          ListTile(
            leading: Icon(link.icon),
            title: Text(link.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(link.location),
          ),
      ],
    );
  }
}

class NavigationLink {
  const NavigationLink({
    required this.label,
    required this.location,
    required this.icon,
  });

  final String label;
  final String location;
  final IconData icon;
}
