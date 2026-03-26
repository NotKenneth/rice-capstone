import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Profile header widget displaying user avatar and editable name
class ProfileHeaderWidget extends StatefulWidget {
  final String userName;
  final String? avatarUrl; // Changed to nullable String
  final Function(String) onNameChanged;
  final VoidCallback onImageTap; // Added callback for image upload

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    this.avatarUrl,
    required this.onNameChanged,
    required this.onImageTap,
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
  void didUpdateWidget(ProfileHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userName != oldWidget.userName && !_isEditing) {
      _nameController.text = widget.userName;
    }
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
      // Set to transparent so the Lottie background shows through
      color: Colors.transparent, 
      child: Column(
        children: [
          // Avatar with Upload Trigger
          GestureDetector(
            onTap: widget.onImageTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 12.5.w,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: widget.avatarUrl == null || widget.avatarUrl!.isEmpty
                      ? CustomIconWidget(
                          iconName: 'person',
                          size: 12.w,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 4.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          // Bright white text while typing
                          color: Colors.white70, 
                        ),
                        autofocus: true,
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
                        // Green accent color for the save checkmark
                        color: Colors.greenAccent, 
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
                          // Bright white text for the saved username
                          color: Colors.white70, 
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'edit',
                        size: 5.w,
                        // Slightly faded white for the edit pencil
                        color: Colors.white70, 
                        
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 1.h),
          Text(
            'Tap photo to change • Long press name to edit',
            style: theme.textTheme.bodySmall?.copyWith(
              // Slightly faded white for the instructions subtitle
              color: Colors.white70, 
            ),
          ),
        ],
      ),
    );
  }
}