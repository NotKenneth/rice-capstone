import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart'; 

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/about_section_widget.dart';
import './widgets/help_support_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_list_item_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

/// Profile screen for user account management and app preferences
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Loading...';
  String? _avatarUrl;
  bool _isDarkMode = false;
  bool _isExporting = false;
  final bool _isOffline = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('first_name, last_name, avatar_url') 
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            String first = data['first_name'] ?? "";
            String last = data['last_name'] ?? "";
            _userName = "$first $last".trim();
            _avatarUrl = data['avatar_url']; 

            if (_userName.isEmpty) _userName = "Farmer";
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _handleImageUpload() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (image == null) return;

    setState(
      () => _isExporting = true,
    ); 

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileName = 'avatar_${user.id}.jpg';
      final bytes = await image.readAsBytes();

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg', 
            ),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      setState(() {
        _avatarUrl = publicUrl;
      });

      _showSnackBar('Profile picture updated!');
    } catch (e) {
      debugPrint("Upload error: $e");
      _showSnackBar('Failed to upload image');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _handleNameChange(String newName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    List<String> parts = newName.split(' ');
    String firstName = parts[0];
    String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'first_name': firstName, 'last_name': lastName})
          .eq('id', user.id);

      setState(() {
        _userName = newName;
      });
      _showSnackBar('Name updated in cloud successfully');
    } catch (e) {
      _showSnackBar('Failed to update name: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }


  void _handleFAQ() {
    _showSnackBar('FAQ - Coming soon');
  }

  void _handleContactSupport() {
    _showSnackBar('Contact Support - Coming soon');
  }

  void _handleAbout() {
    _showAboutDialog();
  }

  Future<void> _handleDataExport() async {
    setState(() {
      _isExporting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isExporting = false;
    });

    _showSnackBar('Data exported successfully');
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

  void _performLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
    }
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
       title: Image.asset(
          'assets/official_logo.png', // <-- Make sure to use your actual asset path
          height: 50, // Adjust this height so it fits well inside the AppBar
          fit: BoxFit.contain,
        ),
        variant: CustomAppBarVariant.standard,
        showNotifications: false,
        showSyncStatus: true,
        syncStatus: _isOffline ? null : true,
      ),
      body: Stack(
        children: [
          // Lottie Background Layer
          Positioned.fill(
            child: Lottie.asset(
              'assets/Background_shooting_star.json', 
              fit: BoxFit.cover, 
            ),
          ),
          
          // Foreground Content Layer
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header with avatar and editable name
                  ProfileHeaderWidget(
                    userName: _userName,
                    avatarUrl: _avatarUrl,
                    onNameChanged: _handleNameChange,
                    onImageTap: _handleImageUpload,
                  ),

                  SizedBox(height: 2.h),

                  SizedBox(height: 1.h),
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
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/profile-screen',
        showOfflineIndicator: _isOffline,
      ),
    );
  }
}