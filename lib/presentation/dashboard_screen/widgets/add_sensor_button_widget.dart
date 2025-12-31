import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

class AddSensorButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSensorButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4.0,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
      label: Text(
        'Add Sensor',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
