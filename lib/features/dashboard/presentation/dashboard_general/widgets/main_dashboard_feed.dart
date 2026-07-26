import 'package:flutter/cupertino.dart';
import 'quick_actions_grid.dart';
import 'recent_organizations_list.dart';
import 'smart_recommendations_section.dart';
import 'upcoming_modules_section.dart';
import 'hero_state_card.dart';

class MainDashboardFeed extends StatelessWidget {
  final bool hasOrganizations;
  final List<Map<String, String>> recommendations;
  final Function(String) onDismissRecommendation;

  const MainDashboardFeed({
    required this.hasOrganizations,
    required this.recommendations,
    required this.onDismissRecommendation,
    super.key, // Agregado para consistencia de buenas prácticas
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const QuickActionsGrid(),
        const SizedBox(height: 24),
        HeroStateCard(hasOrganizations: hasOrganizations),
        const SizedBox(height: 24),

        // ¡Métricas eliminadas de aquí! Ahora viven exclusivamente en el SideControlPanel de forma limpia.

        if (hasOrganizations) ...[
          const RecentOrganizationsList(),
          const SizedBox(height: 24),
        ],
        const UpcomingModulesSection(),
        const SizedBox(height: 24),
        if (recommendations.isNotEmpty)
          SmartRecommendationsSection(
            recommendations: recommendations,
            onDismiss: onDismissRecommendation,
          ),
      ],
    );
  }
}