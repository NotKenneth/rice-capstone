import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Notifications Settings Widget
/// Manages sensor alerts, moisture warnings, and daily summary preferences
class NotificationsSettingsWidget extends StatelessWidget {
  final bool sensorAlerts;
  final bool moistureWarnings;
  final bool dailySummary;
  final ValueChanged<bool> onSensorAlertsChanged;
  final ValueChanged<bool> onMoistureWarningsChanged;
  final ValueChanged<bool> onDailySummaryChanged;

  const NotificationsSettingsWidget({
    super.key,
    required this.sensorAlerts,
    required this.moistureWarnings,
    required this.dailySummary,
    required this.onSensorAlertsChanged,
    required this.onMoistureWarningsChanged,
    required this.onDailySummaryChanged,
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
                  iconName: 'notifications',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Sensor alerts toggle
            _buildNotificationTile(
              context: context,
              icon: 'sensors',
              title: 'Sensor Alerts',
              subtitle: 'Get notified about sensor status changes',
              value: sensorAlerts,
              onChanged: onSensorAlertsChanged,
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Moisture warnings toggle
            _buildNotificationTile(
              context: context,
              icon: 'warning',
              title: 'Moisture Warnings',
              subtitle: 'Alerts when moisture levels reach critical thresholds',
              value: moistureWarnings,
              onChanged: onMoistureWarningsChanged,
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Daily summary toggle
            _buildNotificationTile(
              context: context,
              icon: 'summarize',
              title: 'Daily Summary',
              subtitle: 'Receive daily drying process summary reports',
              value: dailySummary,
              onChanged: onDailySummaryChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
