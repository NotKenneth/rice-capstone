import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Data & Privacy Settings Widget
/// Manages data export, cache management, and privacy policy access
class DataPrivacyWidget extends StatelessWidget {
  final VoidCallback onExportData;
  final VoidCallback onClearCache;
  final VoidCallback onPrivacyPolicy;

  const DataPrivacyWidget({
    super.key,
    required this.onExportData,
    required this.onClearCache,
    required this.onPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Data & Privacy',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Export data option
            _buildActionTile(
              context: context,
              icon: 'file_download',
              title: 'Export Data',
              subtitle: 'Download your sensor data and analysis reports',
              onTap: onExportData,
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Clear cache option
            _buildActionTile(
              context: context,
              icon: 'delete_sweep',
              title: 'Clear Cache',
              subtitle: 'Free up storage by clearing cached data',
              onTap: onClearCache,
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Privacy policy option
            _buildActionTile(
              context: context,
              icon: 'policy',
              title: 'Privacy Policy',
              subtitle: 'Read our data protection and privacy terms',
              onTap: onPrivacyPolicy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'chevron_right',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }
}
