import 'dart:ui'; // Required for ImageFilter
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
      // We apply the ClipRRect to keep the blur constrained to the rounded borders
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              // Translucent gradient for the frosted glass look
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.4),
                  theme.colorScheme.surface.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16.0),
              // Subtle border to simulate the edge of the glass
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
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
                        // Ensure text is readable on translucent background
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.0),
                    // Made the inner border slightly transparent to blend with the glass
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5), 
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedVariety.isEmpty ? null : selectedVariety,
                      hint: Text(
                        "Select Variety", 
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
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
                      // Dropdown menu background 
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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