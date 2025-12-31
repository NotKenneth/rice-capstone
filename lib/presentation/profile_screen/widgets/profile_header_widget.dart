import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Profile header widget displaying user avatar and editable name
class ProfileHeaderWidget extends StatefulWidget {
  final String userName;
  final Function(String) onNameChanged;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.onNameChanged,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        widget.onNameChanged(_nameController.text);
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar placeholder
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                size: 12.w,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Editable name field
          _isEditing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.w,
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'check',
                        size: 6.w,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: _toggleEdit,
                    ),
                  ],
                )
              : GestureDetector(
                  onLongPress: _toggleEdit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'edit',
                        size: 5.w,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 1.h),
          Text(
            'Long press name to edit',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
