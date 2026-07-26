import 'package:flutter/cupertino.dart';
import 'recent_activity_timeline.dart';
import 'security_management_card.dart';
import 'first_steps_checklist.dart';
import 'metrics_summary_block.dart';

class SideControlPanel extends StatelessWidget {
  final List<Map<String, dynamic>> checklistItems;
  final bool showChecklist;
  final Function(int) onToggleCheck;

  final int totalOrganizations;
  final String activeRole;
  final int activeModules;

  const SideControlPanel({
    required this.checklistItems,
    required this.showChecklist,
    required this.onToggleCheck,
    required this.totalOrganizations,
    required this.activeRole,
    required this.activeModules,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showChecklist) ...[
          FirstStepsChecklist(
            items: checklistItems,
            onToggle: onToggleCheck,
          ),
          const SizedBox(height: 24),
        ],
        MetricsSummaryBlock(
          totalOrganizations: totalOrganizations,
          activeRole: activeRole,
          activeModules: activeModules,
        ),
        const SizedBox(height: 24),
        const SecurityManagementCard(),
        const SizedBox(height: 24),
        const RecentActivityTimeline(),
      ],
    );
  }
}