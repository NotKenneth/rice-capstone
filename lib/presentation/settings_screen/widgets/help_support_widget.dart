import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Help & Support Settings Widget
/// Provides FAQ access, contact support, and video tutorials
class HelpSupportWidget extends StatefulWidget {
  const HelpSupportWidget({super.key});

  @override
  State<HelpSupportWidget> createState() => _HelpSupportWidgetState();
}

class _HelpSupportWidgetState extends State<HelpSupportWidget> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      "question": "How do I connect my moisture sensors?",
      "answer":
          "Go to Dashboard, tap the sensor card, and follow the Bluetooth pairing instructions. Ensure sensors are powered on and within range.",
      "isExpanded": false,
    },
    {
      "question": "What do the moisture level colors mean?",
      "answer":
          "Green indicates optimal moisture (12-14%), yellow shows caution (14-16%), and red signals critical levels (>16% or <12%).",
      "isExpanded": false,
    },
    {
      "question": "How often should I calibrate sensors?",
      "answer":
          "Calibrate sensors every 2 weeks or when readings seem inconsistent. Access calibration through Settings > Sensor Settings.",
      "isExpanded": false,
    },
    {
      "question": "Can I export my drying data?",
      "answer":
          "Yes, go to Settings > Data & Privacy > Export Data to download CSV reports of your sensor readings and analysis.",
      "isExpanded": false,
    },
    {
      "question": "What if a sensor shows offline?",
      "answer":
          "Check sensor battery, ensure Bluetooth is enabled, and verify the sensor is within 10 meters. Try manual reconnection from Dashboard.",
      "isExpanded": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'help',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Help & Support',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),

            // FAQ List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqItems.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final item = _faqItems[index];
                return _buildFAQItem(
                  context: context,
                  question: item["question"] as String,
                  answer: item["answer"] as String,
                  isExpanded: item["isExpanded"] as bool,
                  onTap: () {
                    setState(() {
                      _faqItems[index]["isExpanded"] =
                          !(item["isExpanded"] as bool);
                    });
                  },
                );
              },
            ),

            SizedBox(height: 2.h),
            Divider(
              height: 2.h,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            SizedBox(height: 1.h),

            // Contact support button
            _buildActionButton(
              context: context,
              icon: 'email',
              label: 'Contact Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening email client...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            SizedBox(height: 1.h),

            // Video tutorials button
            _buildActionButton(
              context: context,
              icon: 'play_circle',
              label: 'Video Tutorials',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening video tutorials...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 1.h),
                Text(
                  answer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

