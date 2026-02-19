import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

class RiceVarietySelectorWidget extends StatelessWidget {
  final String selectedVariety;
  final List<String> varieties;
  final ValueChanged<String?> onVarietyChanged;

  const RiceVarietySelectorWidget({
    super.key,
    required this.selectedVariety,
    required this.varieties,
    required this.onVarietyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'grass',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Rice Variety',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: theme.colorScheme.primary, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedVariety.isEmpty ? null : selectedVariety,
                hint: const Text("Select Variety"),
                isExpanded: true,
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: theme.colorScheme.surface,
                items: varieties.map((String variety) {
                  return DropdownMenuItem<String>(
                    value: variety,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getVarietyColor(variety, theme),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(variety),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onVarietyChanged,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select rice variety to filter sensors',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getVarietyColor(String variety, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
    ];
    final index = varieties.indexOf(variety) % colors.length;
    return colors[index];
  }
}
