import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
enum CustomBottomBarItem {
  dashboard(
    route: '/dashboard-screen',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
  ),
  analysis(
    route: '/analysis-screen',
    label: 'Analysis',
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics,
  ),
  profile(
    route: '/profile-screen',
    label: 'Profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  );

  const CustomBottomBarItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Custom bottom navigation bar optimized for agricultural field use
/// Features large touch targets suitable for gloved hands and outdoor visibility
class CustomBottomBar extends StatelessWidget {
  /// Current active route path
  final String currentRoute;

  /// Optional callback when navigation item is tapped
  final Function(String route)? onItemTapped;

  /// Optional badge count for notifications (e.g., sensor alerts)
  final Map<CustomBottomBarItem, int>? badges;

  /// Whether to show offline indicator
  final bool showOfflineIndicator;

  const CustomBottomBar({
    super.key,
    required this.currentRoute,
    this.onItemTapped,
    this.badges,
    this.showOfflineIndicator = false,
  });

  int get _currentIndex {
    for (int i = 0; i < CustomBottomBarItem.values.length; i++) {
      if (CustomBottomBarItem.values[i].route == currentRoute) {
        return i;
      }
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final item = CustomBottomBarItem.values[index];

    if (onItemTapped != null) {
      onItemTapped!(item.route);
    } else {
      // Default navigation behavior
      if (currentRoute != item.route) {
        Navigator.pushReplacementNamed(context, item.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Offline indicator banner
            if (showOfflineIndicator)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 14,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Offline Mode',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Navigation bar
            SizedBox(
              height: 64, // Extended height for gloved operation
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  CustomBottomBarItem.values.length,
                  (index) => _buildNavigationItem(
                    context,
                    CustomBottomBarItem.values[index],
                    index == _currentIndex,
                    index,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    bool isSelected,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgeCount = badges?[item] ?? 0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(context, index),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 24, // Standard icon size for clarity
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),

                    // Badge indicator
                    if (badgeCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Label
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Variant with floating action button integration
class CustomBottomBarWithFAB extends StatelessWidget {
  /// Current active route path
  final String currentRoute;

  /// Optional callback when navigation item is tapped
  final Function(String route)? onItemTapped;

  /// Optional badge count for notifications
  final Map<CustomBottomBarItem, int>? badges;

  /// Whether to show offline indicator
  final bool showOfflineIndicator;

  /// Floating action button configuration
  final VoidCallback? onFABPressed;
  final IconData fabIcon;
  final String fabTooltip;

  const CustomBottomBarWithFAB({
    super.key,
    required this.currentRoute,
    this.onItemTapped,
    this.badges,
    this.showOfflineIndicator = false,
    this.onFABPressed,
    this.fabIcon = Icons.add,
    this.fabTooltip = 'Add Sensor',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomBottomBar(
          currentRoute: currentRoute,
          onItemTapped: onItemTapped,
          badges: badges,
          showOfflineIndicator: showOfflineIndicator,
        ),

        // Floating Action Button positioned for thumb reach
        Positioned(
          bottom: 16,
          child: FloatingActionButton(
            onPressed: onFABPressed,
            tooltip: fabTooltip,
            elevation: 4.0,
            child: Icon(fabIcon, size: 24),
          ),
        ),
      ],
    );
  }
}
