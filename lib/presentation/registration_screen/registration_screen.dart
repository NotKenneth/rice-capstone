import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final supabase = Supabase.instance.client;

      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (res.user == null) {
        throw Exception('Registration failed: User creation returned null');
      }

      final String userId = res.user!.id;

      List<String> nameParts = _nameController.text.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      await supabase.from('profiles').insert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email_address': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'location': _selectedLocation,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        _showErrorSnackBar('Database error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';

        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection.';
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
        // ... (keep your existing styling code) ...
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (keep your existing icon and text widgets) ...
            SizedBox(height: 3.h),

            // THE NAVIGATION BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 1. Close the Dialog popup
                  Navigator.of(context).pop();

                  // 2. Navigate to Dashboard and remove back history
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard-screen', // Make sure this matches your routes name exactly
                    (Route<dynamic> route) =>
                        false, // This condition removes all previous routes
                  );
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
