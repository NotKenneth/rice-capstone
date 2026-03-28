import 'package:flutter/material.dart';

/// App bar variant types for different screen contexts
enum CustomAppBarVariant { standard, withBackButton, withSearch, transparent }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Changed from String to dynamic so it can accept a String OR a Widget (like an Image)
  final dynamic title; 
  final CustomAppBarVariant variant;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showSyncStatus;
  final bool? syncStatus;
  final Function(String)? onSearch;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final bool showNotifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final bool automaticallyImplyLeading; 

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
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.showNotifications = false,
    this.automaticallyImplyLeading = true, 
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
      automaticallyImplyLeading: automaticallyImplyLeading, 
      backgroundColor: backgroundColor ??
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
    
    // Checks if the title is already a Widget (like an Image). If not, formats it as Text.
    Widget mainTitle = title is Widget 
        ? title 
        : Text(
            title.toString(),
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          mainTitle,
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    return mainTitle;
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (variant == CustomAppBarVariant.withBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }
    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    if (showSyncStatus) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _buildSyncIndicator(theme, syncStatus),
        ),
      );
    }

    if (showNotifications) {
      actionWidgets.add(
        _NotificationBell(
          count: unreadNotificationCount,
          onTap: onNotificationTap,
        ),
      );
    }

    if (variant == CustomAppBarVariant.withSearch && onSearch != null) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context, onSearch!),
        ),
      );
    }

    if (actions != null) actionWidgets.addAll(actions!);

    return actionWidgets;
  }
}

/// Sliver variant for use in CustomScrollView
class CustomSliverAppBar extends StatelessWidget {
  // Changed from String to dynamic here as well
  final dynamic title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showSyncStatus;
  final bool? syncStatus;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final bool automaticallyImplyLeading; 

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
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.automaticallyImplyLeading = true, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      title: _buildTitle(context),
      leading: leading,
      actions: _buildActions(context),
      automaticallyImplyLeading: automaticallyImplyLeading, 
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
    
    // Applying the same Widget/String check logic here
    Widget mainTitle = title is Widget 
        ? title 
        : Text(
            title.toString(),
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          mainTitle,
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    return mainTitle;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    if (showSyncStatus) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildSyncIndicator(theme, syncStatus),
        ),
      );
    }

    actionWidgets.add(
      _NotificationBell(
        count: unreadNotificationCount,
        onTap: onNotificationTap,
      ),
    );

    if (actions != null) actionWidgets.addAll(actions!);

    return actionWidgets;
  }
}

// --- Helper Widgets to avoid code duplication ---

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationBell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 26),
          onPressed: onTap,
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

Widget _buildSyncIndicator(ThemeData theme, bool? syncStatus) {
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

void _showSearchDialog(BuildContext context, Function(String) onSearch) {
  showDialog(
    context: context,
    builder: (context) => _SearchDialog(onSearch: onSearch),
  );
}

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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch(value);
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onSearch(_controller.text);
                      Navigator.pop(context);
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