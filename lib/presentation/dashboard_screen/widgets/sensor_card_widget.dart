import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

class SensorCardWidget extends StatelessWidget {
  final String sensorId;
  final double moisturePercentage;
  final String status;
  final DateTime lastUpdate;
  final String connectionStatus;
  final String riceVariety;
  final VoidCallback onTap;

  const SensorCardWidget({
    super.key,
    required this.sensorId,
    required this.moisturePercentage,
    required this.status,
    required this.lastUpdate,
    required this.connectionStatus,
    required this.riceVariety,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status, theme);
    final connectionColor = _getConnectionColor(connectionStatus, theme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: statusColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with sensor ID and connection status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sensorId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: connectionColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Moisture percentage display
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'water_drop',
                        color: statusColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${moisturePercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Moisture',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Status indicator
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _getStatusIcon(status),
                        color: statusColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Last update time
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getTimeAgo(lastUpdate),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return const Color(0xFF4CAF50);
      case 'warning':
        return const Color(0xFFFF9800);
      case 'critical':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getConnectionColor(String connectionStatus, ThemeData theme) {
    switch (connectionStatus.toLowerCase()) {
      case 'connected':
        return const Color(0xFF4CAF50);
      case 'weak':
        return const Color(0xFFFF9800);
      case 'disconnected':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.3);
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return 'check_circle';
      case 'warning':
        return 'warning';
      case 'critical':
        return 'error';
      default:
        return 'info';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
