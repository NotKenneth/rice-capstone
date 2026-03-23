import 'dart:ui'; // Required for ImageFilter (the blur effect)
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual settings list item with icon and disclosure indicator, now Glassmorphic!
class SettingsListItemWidget extends StatelessWidget {
  final String title;
  final String iconName;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsListItemWidget({
    super.key,
    required this.title,
    required this.iconName,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // The Glassmorphic Wrapper
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // A subtle border is crucial for the glass effect
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
              // This creates the frosted blur over your animated background
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), 
              child: Material(
                // Semi-transparent white overlay
                color: Colors.white.withValues(alpha: 0.1), 
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      children: [
                        // Glassy Icon Container
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            // Slightly more opaque glass for the icon box
                            color: Colors.white.withValues(alpha: 0.15), 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: iconName,
                              size: 6.w,
                              color: Colors.white, // Bright white icon
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),

                        // Title Text
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Bright white text
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Disclosure indicator (Chevron)
                        CustomIconWidget(
                          iconName: 'chevron_right',
                          size: 6.w,
                          color: Colors.white.withValues(alpha: 0.6), // Faded white
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Glassy Divider (I made it fainter so it matches the theme)
        if (showDivider)
          Divider(
            height: 1.5.h,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.1), 
            indent: 6.w,
            endIndent: 6.w,
          ),
      ],
    );
  }
}