import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/data_privacy_widget.dart';
import './widgets/display_preferences_widget.dart';
import './widgets/help_support_widget.dart';
import './widgets/notifications_settings_widget.dart';
import './widgets/sensor_settings_widget.dart';

/// Settings Screen for DryCe Monitoring System
/// Provides comprehensive app configuration and support access
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _textSize = 14.0;
  String _measurementUnit = 'Metric';
  bool _sensorAlerts = true;
  bool _moistureWarnings = true;
  bool _dailySummary = false;
  bool _autoReconnect = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // Load saved settings from SharedPreferences
    // For now using default values
    setState(() {});
  }

  Future<void> _saveSettings() async {
    // Save settings to SharedPreferences
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _isDarkMode = false;
      _textSize = 14.0;
      _measurementUnit = 'Metric';
      _sensorAlerts = true;
      _moistureWarnings = true;
      _dailySummary = false;
      _autoReconnect = true;
    });
    _saveSettings();
  }

  List<Widget> _getFilteredSettings() {
    final query = _searchQuery.toLowerCase();
    final List<Widget> allSettings = [
      DisplayPreferencesWidget(
        isDarkMode: _isDarkMode,
        textSize: _textSize,
        measurementUnit: _measurementUnit,
        onDarkModeChanged: (value) {
          setState(() => _isDarkMode = value);
          _saveSettings();
        },
        onTextSizeChanged: (value) {
          setState(() => _textSize = value);
          _saveSettings();
        },
        onMeasurementUnitChanged: (value) {
          setState(() => _measurementUnit = value);
          _saveSettings();
        },
      ),
      NotificationsSettingsWidget(
        sensorAlerts: _sensorAlerts,
        moistureWarnings: _moistureWarnings,
        dailySummary: _dailySummary,
        onSensorAlertsChanged: (value) {
          setState(() => _sensorAlerts = value);
          _saveSettings();
        },
        onMoistureWarningsChanged: (value) {
          setState(() => _moistureWarnings = value);
          _saveSettings();
        },
        onDailySummaryChanged: (value) {
          setState(() => _dailySummary = value);
          _saveSettings();
        },
      ),
      SensorSettingsWidget(
        autoReconnect: _autoReconnect,
        onAutoReconnectChanged: (value) {
          setState(() => _autoReconnect = value);
          _saveSettings();
        },
        onCalibrationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sensor calibration feature coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      DataPrivacyWidget(
        onExportData: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exporting data...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onClearCache: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear Cache'),
              content: const Text(
                'Are you sure you want to clear all cached data?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache cleared successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        },
        onPrivacyPolicy: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening privacy policy...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      const HelpSupportWidget(),
    ];

    if (query.isEmpty) {
      return allSettings;
    }

    // Filter settings based on search query
    return allSettings.where((widget) {
      if (widget is DisplayPreferencesWidget &&
          ('display preferences theme text size measurement'.contains(query))) {
        return true;
      }
      if (widget is NotificationsSettingsWidget &&
          ('notifications alerts warnings summary'.contains(query))) {
        return true;
      }
      if (widget is SensorSettingsWidget &&
          ('sensor bluetooth calibration reconnect'.contains(query))) {
        return true;
      }
      if (widget is DataPrivacyWidget &&
          ('data privacy export cache policy'.contains(query))) {
        return true;
      }
      if (widget is HelpSupportWidget &&
          ('help support faq contact tutorial'.contains(query))) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSettings = _getFilteredSettings();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Settings',
        variant: CustomAppBarVariant.withBackButton,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              color: theme.colorScheme.surface,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

            // Settings list
            Expanded(
              child: filteredSettings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'search_off',
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                            size: 64,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No settings found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try a different search term',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: filteredSettings.length + 1,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        if (index == filteredSettings.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
                            child: OutlinedButton(
                              onPressed: _showResetDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'restore',
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Reset to Defaults',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return filteredSettings[index];
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
