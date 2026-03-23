import 'dart:ui'; // <-- Added this for ImageFilter
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
      backgroundColor: Colors.transparent, // This is required for the glass effect to show through!
      builder: (context) => AnalysisInsightsSheetWidget(insights: insights),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Wrap with ClipRRect to keep the blur inside your rounded corners
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      // 2. Apply the BackdropFilter for the blur
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // Tweak these values for more/less blur
        child: Container(
          decoration: BoxDecoration(
            // 3. Make the surface color semi-transparent (adjust alpha as needed)
            color: theme.colorScheme.surface.withValues(alpha: 0.4), 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            // Optional: A subtle border on top helps define the "glass" edge
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5), // Made slightly transparent
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
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)), // Softened divider
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
        ),
      ),
    );
  }
}