import 'dart:ui';
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
      child: ClipRRect(
        // Larger border radius to match the login card style
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          // Significantly higher blur for that smooth, deep frosted look
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              // Dark, neutral gradient overlay to let the bright background pop while keeping text readable
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(24.0),
              // Very faint white edge highlight
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CustomIconWidget(
                      iconName: 'grass',
                      color: Colors.white, // Changed to white for high contrast
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Rice Variety',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Forced white for high contrast
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dropdown Container - styled like the login input fields
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    // Dark inner background to mimic the email/password fields
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1.0,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedVariety.isEmpty ? null : selectedVariety,
                      hint: Text(
                        "Select Variety", 
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      isExpanded: true,
                      icon: const CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: Colors.white60,
                        size: 24,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      // Solid dark background for the opened dropdown menu
                      dropdownColor: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12.0),
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
                                Text(variety, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onVarietyChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select rice variety to filter sensors',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
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