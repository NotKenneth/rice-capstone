import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/about_section_widget.dart';
import './widgets/data_export_widget.dart';
import './widgets/help_support_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_list_item_widget.dart';
import './widgets/theme_toggle_widget.dart';

/// Profile screen for user account management and app preferences
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'John Farmer';
  bool _isDarkMode = false;
  bool _isExporting = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading user preferences
    await Future.delayed(const Duration(milliseconds: 500));
    // In production, load from SharedPreferences or secure storage
  }

  void _handleNameChange(String newName) {
    setState(() {
      _userName = newName;
    });
    _showSnackBar('Name updated successfully');
    // In production, save to backend and local storage
  }

  void _handleThemeToggle(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    _showSnackBar(isDark ? 'Dark mode enabled' : 'Light mode enabled');
    // In production, update theme provider and save preference
  }

  void _handleAccountSettings() {
    _showSnackBar('Account Settings - Coming soon');
    // Navigate to account settings screen
  }

  void _handleSensorManagement() {
    _showSnackBar('Sensor Management - Coming soon');
    // Navigate to sensor management screen
  }

  void _handleNotifications() {
    _showSnackBar('Notifications - Coming soon');
    // Navigate to notifications settings screen
  }

  void _handleAppPreferences() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  void _handleFAQ() {
    _showSnackBar('FAQ - Coming soon');
    // Navigate to FAQ screen or show FAQ dialog
  }

  void _handleContactSupport() {
    _showSnackBar('Contact Support - Coming soon');
    // Open contact support dialog or navigate to support screen
  }

  void _handleAbout() {
    _showAboutDialog();
  }

  Future<void> _handleDataExport() async {
    setState(() {
      _isExporting = true;
    });

    // Simulate data export process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isExporting = false;
    });

    _showSnackBar('Data exported successfully');
    // In production, generate and download actual export file
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to logout? Any unsaved data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Clear user session and navigate to login
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'agriculture',
              size: 6.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            const Text('About DryCe'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DryCe Monitoring System',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Text('Version 1.0.0', style: theme.textTheme.bodyMedium),
              SizedBox(height: 2.h),
              Text(
                'IoT-enabled agricultural monitoring application for rice drying process management with real-time sensor integration.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              const Divider(),
              SizedBox(height: 1.h),
              Text(
                'Sensor Compatibility',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '• Bluetooth Low Energy (BLE) 4.0+\n• Wi-Fi enabled moisture sensors\n• Real-time data synchronization',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Certifications',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '• Agricultural IoT Certified\n• Data Security Compliant\n• Sensor Accuracy Verified',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        variant: CustomAppBarVariant.standard,
        showSyncStatus: true,
        syncStatus: _isOffline ? null : true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with avatar and editable name
              ProfileHeaderWidget(
                userName: _userName,
                onNameChanged: _handleNameChange,
              ),

              SizedBox(height: 2.h),

              // Settings options list
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(height: 1.h),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    SettingsListItemWidget(
                      title: 'Account Settings',
                      iconName: 'person',
                      onTap: _handleAccountSettings,
                    ),
                    SettingsListItemWidget(
                      title: 'Sensor Management',
                      iconName: 'sensors',
                      onTap: _handleSensorManagement,
                    ),
                    SettingsListItemWidget(
                      title: 'Notifications',
                      iconName: 'notifications',
                      onTap: _handleNotifications,
                    ),
                    SettingsListItemWidget(
                      title: 'App Preferences',
                      iconName: 'settings',
                      onTap: _handleAppPreferences,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Theme toggle
              ThemeToggleWidget(
                isDarkMode: _isDarkMode,
                onToggle: _handleThemeToggle,
              ),

              SizedBox(height: 2.h),

              // Data export
              DataExportWidget(
                onExportTap: _handleDataExport,
                isExporting: _isExporting,
              ),

              SizedBox(height: 2.h),

              // Help & Support section
              HelpSupportSectionWidget(
                onFAQTap: _handleFAQ,
                onContactTap: _handleContactSupport,
              ),

              SizedBox(height: 2.h),

              // About section
              AboutSectionWidget(appVersion: '1.0.0', onTap: _handleAbout),

              SizedBox(height: 3.h),

              // Logout button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'logout',
                          size: 5.w,
                          color: theme.colorScheme.onError,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Logout',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/profile-screen',
        showOfflineIndicator: _isOffline,
      ),
    );
  }
}
