import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet with analysis insights and recommendations
class AnalysisInsightsSheetWidget extends StatelessWidget {
  final List<Map<String, dynamic>> insights;

  const AnalysisInsightsSheetWidget({super.key, required this.insights});

  static void show(BuildContext context, List<Map<String, dynamic>> insights) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnalysisInsightsSheetWidget(insights: insights),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analysis Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: insights.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final insight = insights[index];
                final type = insight['type'] as String;
                final title = insight['title'] as String;
                final description = insight['description'] as String;

                Color iconColor;
                String iconName;

                switch (type) {
                  case 'success':
                    iconColor = theme.colorScheme.primary;
                    iconName = 'check_circle';
                    break;
                  case 'warning':
                    iconColor = const Color(0xFFF57C00);
                    iconName = 'warning';
                    break;
                  case 'info':
                    iconColor = const Color(0xFF1976D2);
                    iconName = 'info';
                    break;
                  default:
                    iconColor = theme.colorScheme.onSurface;
                    iconName = 'lightbulb';
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: iconName,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(description, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
