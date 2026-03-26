import 'dart:ui'; // Required for the glass blur effect
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Help and support section with FAQ and contact information - Glassmorphic Edition
class HelpSupportSectionWidget extends StatelessWidget {
  final VoidCallback onFAQTap;
  final VoidCallback onContactTap;

  const HelpSupportSectionWidget({
    super.key,
    required this.onFAQTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Subtle white border for the glass edge
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // The frosted glass blur
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            // Semi-transparent white overlay
            color: Colors.white.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    'Help & Support',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white, // Bright white text
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.2), // Faded white divider
                ),

                // FAQ Item
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onFAQTap,
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'help_outline',
                            size: 6.w,
                            color: Colors.white, // Bright white icon
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Frequently Asked Questions',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white, // Bright white text
                              ),
                            ),
                          ),
                          CustomIconWidget(
                            iconName: 'chevron_right',
                            size: 6.w,
                            color: Colors.white.withValues(alpha: 0.6), // Faded white chevron
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.2), // Faded white divider
                  indent: 4.w,
                  endIndent: 4.w,
                ),

                // Contact Support Item
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onContactTap,
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'contact_support',
                            size: 6.w,
                            color: Colors.white, // Bright white icon
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Contact Support',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white, // Bright white text
                              ),
                            ),
                          ),
                          CustomIconWidget(
                            iconName: 'chevron_right',
                            size: 6.w,
                            color: Colors.white.withValues(alpha: 0.6), // Faded white chevron
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}