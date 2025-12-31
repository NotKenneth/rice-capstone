import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/registration_button_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';

/// Registration screen for new farmer account creation
/// Implements agricultural context-aware form design optimized for mobile input
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedLocation;
  bool _termsAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _selectedLocation != null &&
        _selectedLocation != 'Select Farm Location' &&
        _termsAccepted;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      _showErrorSnackBar(
        'Please accept the Terms of Service and Privacy Policy',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation - check for existing email
      if (_emailController.text.toLowerCase() == 'existing@example.com') {
        throw Exception('Email already exists');
      }

      // Mock password strength check
      if (_passwordController.text.length < 8) {
        throw Exception('Password is too weak');
      }

      // Show success animation
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';

        if (e.toString().contains('Email already exists')) {
          errorMessage =
              'This email is already registered. Please login instead.';
        } else if (e.toString().contains('weak')) {
          errorMessage = 'Password does not meet security requirements.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        }

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: Theme.of(context).colorScheme.primary,
                  size: 12.w,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Welcome to DryCe!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your farm account has been created successfully. Let\'s set up your moisture sensors.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/dashboard-screen');
                },
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Theme.of(context).colorScheme.onError,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomImageWidget(
                  imageUrl:
                      'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Rice field with green rice plants growing in rows under sunlight',
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                // App Bar with Back Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: theme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/login-screen',
                          );
                        },
                      ),
                      Text('Back to Login', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),

                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),

                        // Header Section
                        const RegistrationHeaderWidget(),
                        SizedBox(height: 4.h),

                        // Registration Form
                        RegistrationFormWidget(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          selectedLocation: _selectedLocation,
                          onLocationChanged: (value) {
                            setState(() => _selectedLocation = value);
                          },
                          termsAccepted: _termsAccepted,
                          onTermsChanged: (value) {
                            setState(() => _termsAccepted = value ?? false);
                          },
                        ),
                        SizedBox(height: 4.h),

                        // Registration Button
                        RegistrationButtonWidget(
                          isLoading: _isLoading,
                          isEnabled: _isFormValid,
                          onPressed: _handleRegistration,
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
