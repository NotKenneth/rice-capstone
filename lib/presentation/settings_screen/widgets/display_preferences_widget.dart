import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Display Preferences Settings Widget
/// Manages theme, text size, and measurement unit preferences
class DisplayPreferencesWidget extends StatelessWidget {
  final bool isDarkMode;
  final double textSize;
  final String measurementUnit;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<double> onTextSizeChanged;
  final ValueChanged<String> onMeasurementUnitChanged;

  const DisplayPreferencesWidget({
    super.key,
    required this.isDarkMode,
    required this.textSize,
    required this.measurementUnit,
    required this.onDarkModeChanged,
    required this.onTextSizeChanged,
    required this.onMeasurementUnitChanged,
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
                  iconName: 'display_settings',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Display Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Dark mode toggle
            _buildSettingTile(
              context: context,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark theme',
              trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
                activeThumbColor: theme.colorScheme.primary,
              ),
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Text size adjustment
            _buildSettingTile(
              context: context,
              title: 'Text Size',
              subtitle: 'Adjust text size for better readability',
              trailing: null,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  'A',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: textSize,
                    min: 12.0,
                    max: 20.0,
                    divisions: 8,
                    label: '${textSize.toInt()}sp',
                    onChanged: onTextSizeChanged,
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'A',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                'Preview: ${textSize.toInt()}sp',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: textSize,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),

            Divider(
              height: 3.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),

            // Measurement unit selection
            _buildSettingTile(
              context: context,
              title: 'Measurement Unit',
              subtitle: 'Choose your preferred measurement system',
              trailing: null,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildUnitButton(
                    context: context,
                    label: 'Metric',
                    isSelected: measurementUnit == 'Metric',
                    onTap: () => onMeasurementUnitChanged('Metric'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildUnitButton(
                    context: context,
                    label: 'Imperial',
                    isSelected: measurementUnit == 'Imperial',
                    onTap: () => onMeasurementUnitChanged('Imperial'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
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
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildUnitButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
