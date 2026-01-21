import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Registration form widget containing all input fields and validation
class RegistrationFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final String? selectedLocation;
  final Function(String?) onLocationChanged;
  final bool termsAccepted;
  final Function(bool?) onTermsChanged;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.termsAccepted,
    required this.onTermsChanged,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  bool _obscurePassword = true;
  bool _nameValid = false;
  bool _emailValid = false;
  bool _phoneValid = false;
  bool _passwordValid = false;

  final List<String> _farmLocations = [
    'Select Farm Location',
    'Northern Region',
    'Central Region',
    'Southern Region',
    'Eastern Region',
    'Western Region',
    'Coastal Region',
  ];

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _nameValid = false);
      return 'Full name is required';
    }
    if (value.length < 3) {
      setState(() => _nameValid = false);
      return 'Name must be at least 3 characters';
    }
    setState(() => _nameValid = true);
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _emailValid = false);
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (!emailRegex.hasMatch(value.trim())) {
      setState(() => _emailValid = false);
      return 'Enter a valid email address';
    }

    setState(() => _emailValid = true);
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _phoneValid = false);
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      setState(() => _phoneValid = false);
      return 'Enter a valid phone number';
    }
    setState(() => _phoneValid = true);
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _passwordValid = false);
      return 'Password is required';
    }
    if (value.length < 8) {
      setState(() => _passwordValid = false);
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      setState(() => _passwordValid = false);
      return 'Password must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      setState(() => _passwordValid = false);
      return 'Password must contain lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      setState(() => _passwordValid = false);
      return 'Password must contain a number';
    }
    setState(() => _passwordValid = true);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          TextFormField(
            controller: widget.nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: _validateName,
            onChanged: (value) => _validateName(value),
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: _nameValid
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 2.h),

          // Email Field
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            onChanged: (value) => _validateEmail(value),
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: _emailValid
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 2.h),

          // Phone Field
          TextFormField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: _validatePhone,
            onChanged: (value) => _validatePhone(value),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'phone',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: _phoneValid
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 2.h),

          // Farm Location Dropdown
          DropdownButtonFormField<String>(
            initialValue: widget.selectedLocation,
            decoration: InputDecoration(
              labelText: 'Farm Location',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
            ),
            items: _farmLocations.map((location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: widget.onLocationChanged,
            validator: (value) {
              if (value == null || value == 'Select Farm Location') {
                return 'Please select your farm location';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Password Field
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onChanged: (value) => _validatePassword(value),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a secure password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _passwordValid
                      ? Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: CustomIconWidget(
                            iconName: 'check_circle',
                            color: theme.colorScheme.primary,
                            size: 5.w,
                          ),
                        )
                      : const SizedBox.shrink(),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: _obscurePassword
                          ? 'visibility'
                          : 'visibility_off',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Password Requirements
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Requirements:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildRequirement(
                  theme,
                  'Minimum 8 characters',
                  widget.passwordController.text.length >= 8,
                ),
                _buildRequirement(
                  theme,
                  'Contains uppercase letter',
                  widget.passwordController.text.contains(RegExp(r'[A-Z]')),
                ),
                _buildRequirement(
                  theme,
                  'Contains lowercase letter',
                  widget.passwordController.text.contains(RegExp(r'[a-z]')),
                ),
                _buildRequirement(
                  theme,
                  'Contains number',
                  widget.passwordController.text.contains(RegExp(r'[0-9]')),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Terms and Conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: widget.termsAccepted,
                onChanged: widget.onTermsChanged,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 1.5.h),
                  child: Wrap(
                    children: [
                      Text(
                        'I agree to the ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Terms of Service
                        },
                        child: Text(
                          'Terms of Service',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(' and ', style: theme.textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Privacy Policy
                        },
                        child: Text(
                          'Privacy Policy',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(ThemeData theme, String text, bool met) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: met ? 'check_circle' : 'radio_button_unchecked',
            color: met
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: met
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
