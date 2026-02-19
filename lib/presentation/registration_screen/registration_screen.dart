import 'dart:ui'; // NEW: Required for the frosted glass effect
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NEW: Required for HapticFeedback
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
      HapticFeedback.heavyImpact(); // Premium error feedback
      return;
    }

    if (!_termsAccepted) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar(
        'Please accept the Terms of Service and Privacy Policy',
      );
      return;
    }

    HapticFeedback.lightImpact();
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
        HapticFeedback.mediumImpact(); // Success feedback
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

  // REFACTORED: Premium Dark Mode Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900], // Dark premium background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.greenAccent[400],
                size: 12.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Account Created!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your farmer profile is ready.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard-screen',
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REFACTORED: Dark Mode SnackBar
  void _showErrorSnackBar(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 5.w),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[900]?.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Let background bleed under top area
      body: Stack(
        children: [
          // 1. Premium Dark Background
          Positioned.fill(
            child: Image.asset(
              'assets/login_background.jpg', // Re-using the login background
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // Refactored Back Button (White/Glassy)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushReplacementNamed(context, '/login-screen');
                        },
                      ),
                      Text(
                        'Back to Login', 
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form Container
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // The child widgets
                              const RegistrationHeaderWidget(),
                              SizedBox(height: 4.h),

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
                                  HapticFeedback.selectionClick();
                                  setState(() => _termsAccepted = value ?? false);
                                },
                              ),
                              SizedBox(height: 4.h),

                              RegistrationButtonWidget(
                                isLoading: _isLoading,
                                isEnabled: _isFormValid,
                                onPressed: _handleRegistration,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}