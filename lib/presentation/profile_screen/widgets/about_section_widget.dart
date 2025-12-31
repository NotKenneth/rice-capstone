import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// About section displaying app version and certifications
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      size: 6.w,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'About DryCe',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 6.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
    );
  }

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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
