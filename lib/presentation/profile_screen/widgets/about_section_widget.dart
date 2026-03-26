import 'dart:ui'; // Required for the glass blur effect
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// About section displaying app version and certifications - Glassmorphic Edition
class AboutSectionWidget extends StatelessWidget {
  final String appVersion;
  final VoidCallback onTap;

  const AboutSectionWidget({
    super.key,
    required this.appVersion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Delicate white border for the glass edge
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // The frosted glass blur
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            // Semi-transparent white overlay
            color: Colors.white.withValues(alpha: 0.1),
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info_outline',
                          size: 6.w,
                          color: Colors.white, // Bright white icon
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'About DryCe',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Bright white text
                            ),
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'chevron_right',
                          size: 6.w,
                          color: Colors.white.withValues(alpha: 0.6), // Faded white chevron
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // App version
                    _buildInfoRow(context, 'Version', appVersion),
                    SizedBox(height: 1.h),

                    // Sensor compatibility
                    _buildInfoRow(
                      context,
                      'Sensor Compatibility',
                      'BLE 4.0+ Moisture Sensors',
                    ),
                    SizedBox(height: 1.h),

                    // Certifications
                    _buildInfoRow(
                      context,
                      'Certifications',
                      'Agricultural IoT Certified',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method updated with white text colors
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 35.w,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Faded white for labels so the values stand out more
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white, // Bright white for values
            ),
          ),
        ),
      ],
    );
  }
}