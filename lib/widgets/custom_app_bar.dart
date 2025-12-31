import 'package:flutter/material.dart';

/// App bar variant types for different screen contexts
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button for navigation stack
  withBackButton,

  /// App bar with search functionality
  withSearch,

  /// Transparent app bar for overlays
  transparent,
}

/// Custom app bar optimized for agricultural monitoring application
/// Provides clear hierarchy and outdoor-readable design
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title text
  final String title;

  /// App bar variant type
  final CustomAppBarVariant variant;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (overrides default back button if provided)
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show sync status indicator
  final bool showSyncStatus;

  /// Sync status (true = synced, false = syncing, null = offline)
  final bool? syncStatus;

  /// Optional callback for search functionality
  final Function(String)? onSearch;

  /// Whether to center the title
  final bool centerTitle;

  /// Optional background color override
  final Color? backgroundColor;

  /// Elevation value (0-4 for subtle hierarchy)
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.subtitle,
    this.leading,
    this.actions,
    this.showSyncStatus = false,
    this.syncStatus,
    this.onSearch,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 2.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ??
          (variant == CustomAppBarVariant.transparent
              ? Colors.transparent
              : colorScheme.surface),
      foregroundColor: colorScheme.onSurface,
      elevation: variant == CustomAppBarVariant.transparent ? 0 : elevation,
      shadowColor: colorScheme.shadow,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      title,
      style: theme.textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (variant == CustomAppBarVariant.withBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
        iconSize: 24,
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    // Add sync status indicator
    if (showSyncStatus) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildSyncIndicator(theme),
        ),
      );
    }

    // Add search button for search variant
    if (variant == CustomAppBarVariant.withSearch && onSearch != null) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
          tooltip: 'Search',
          iconSize: 24,
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isEmpty ? null : actionWidgets;
  }

  Widget _buildSyncIndicator(ThemeData theme) {
    IconData icon;
    Color color;
    String tooltip;

    if (syncStatus == null) {
      icon = Icons.cloud_off;
      color = theme.colorScheme.error;
      tooltip = 'Offline';
    } else if (syncStatus == true) {
      icon = Icons.cloud_done;
      color = theme.colorScheme.primary;
      tooltip = 'Synced';
    } else {
      icon = Icons.cloud_sync;
      color = theme.colorScheme.secondary;
      tooltip = 'Syncing...';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 20, color: color),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(onSearch: onSearch!),
    );
  }
}

/// Search dialog for app bar search functionality
class _SearchDialog extends StatefulWidget {
  final Function(String) onSearch;

  const _SearchDialog({required this.onSearch});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter search term...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onSearch(_controller.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliver variant for use in CustomScrollView
class CustomSliverAppBar extends StatelessWidget {
  /// App bar title text
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show sync status indicator
  final bool showSyncStatus;

  /// Sync status (true = synced, false = syncing, null = offline)
  final bool? syncStatus;

  /// Whether the app bar should float
  final bool floating;

  /// Whether the app bar should pin when scrolled
  final bool pinned;

  /// Whether the app bar should snap
  final bool snap;

  /// Expanded height for flexible space
  final double? expandedHeight;

  /// Flexible space widget
  final Widget? flexibleSpace;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showSyncStatus = false,
    this.syncStatus,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      title: _buildTitle(context),
      leading: leading,
      actions: _buildActions(context),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      shadowColor: colorScheme.shadow,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      title,
      style: theme.textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    if (showSyncStatus) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildSyncIndicator(theme),
        ),
      );
    }

    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isEmpty ? null : actionWidgets;
  }

  Widget _buildSyncIndicator(ThemeData theme) {
    IconData icon;
    Color color;
    String tooltip;

    if (syncStatus == null) {
      icon = Icons.cloud_off;
      color = theme.colorScheme.error;
      tooltip = 'Offline';
    } else if (syncStatus == true) {
      icon = Icons.cloud_done;
      color = theme.colorScheme.primary;
      tooltip = 'Synced';
    } else {
      icon = Icons.cloud_sync;
      color = theme.colorScheme.secondary;
      tooltip = 'Syncing...';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 20, color: color),
    );
  }
}
