import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Header widget with agricultural branding and welcome message
class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Title
        Text(
          'Create Your Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),

        // Subtitle
        Text(
          'Join DryCe to monitor your rice drying process with real-time sensor data and comprehensive analysis.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
