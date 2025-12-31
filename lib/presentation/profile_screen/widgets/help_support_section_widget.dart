import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Help and support section with FAQ and contact information
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Help & Support',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),

          // FAQ
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFAQTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'help_outline',
                      size: 6.w,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Frequently Asked Questions',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 6.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            indent: 4.w,
            endIndent: 4.w,
          ),

          // Contact Support
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onContactTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'contact_support',
                      size: 6.w,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Contact Support',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      size: 6.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
