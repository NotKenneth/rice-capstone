import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Registration action button with loading state
class RegistrationButtonWidget extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const RegistrationButtonWidget({
    super.key,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.12,
              ),
              disabledForegroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Setting up your farm account...',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Create Account',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 2.h),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: theme.textTheme.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: Text(
                'Login',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
