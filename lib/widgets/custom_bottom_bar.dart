import 'dart:ui'; // Required for ImageFilter
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

/// Custom bottom navigation bar - Glassmorphism Floating Pill
class CustomBottomBar extends StatelessWidget {
  final String currentRoute;
  final Function(String route)? onItemTapped;
  final Map<CustomBottomBarItem, int>? badges;
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
      if (currentRoute != item.route) {
        Navigator.pushReplacementNamed(context, item.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Grab the system's bottom padding (for the home indicator / nav bar)
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // SafeArea removed to allow the background to bleed to the absolute bottom
    return Column(
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

        // Glassmorphism Floating Pill Navigation Bar
        Container(
          // Add the system's bottom padding to your existing margin
          // This pushes the pill up without blocking the background behind it
          margin: EdgeInsets.only(
            left: 20, 
            right: 20, 
            bottom: 24 + bottomPadding, 
            top: 8
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), // Softer shadow for glass
                blurRadius: 20.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          // ClipRRect is crucial to keep the blur contained to the pill shape
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // The glass blur
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  // Deep, highly transparent tint
                  color: const Color(0xFF1B2230).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(40),
                  // Thin, bright border to simulate the glass edge catching light
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    bool isSelected,
    int index,
  ) {
    final theme = Theme.of(context);
    final badgeCount = badges?[item] ?? 0;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: isSelected
              ? BoxDecoration(
                  // Slightly more opaque inner pill for the active state
                  color: const Color(0xFF8AB4F8).withValues(alpha: 0.15), 
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF8AB4F8).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
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
                    size: 26,
                    color: isSelected
                        ? const Color(0xFFE8F0FE)
                        : Colors.white.withValues(alpha: 0.6), // Frostier inactive icon
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
                            color: Colors.white.withValues(alpha: 0.2), // Glassy badge border
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

              const SizedBox(height: 6),

              // Label
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? const Color(0xFFE8F0FE)
                      : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant with floating action button integration
class CustomBottomBarWithFAB extends StatelessWidget {
  final String currentRoute;
  final Function(String route)? onItemTapped;
  final Map<CustomBottomBarItem, int>? badges;
  final bool showOfflineIndicator;
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
    // Grab padding here as well
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomBottomBar(
          currentRoute: currentRoute,
          onItemTapped: onItemTapped,
          badges: badges,
          showOfflineIndicator: showOfflineIndicator,
        ),
        
        Positioned(
          // Dynamically adjust the FAB position to match the pill's new padding
          bottom: 110 + bottomPadding, 
          child: FloatingActionButton(
            onPressed: onFABPressed,
            tooltip: fabTooltip,
            elevation: 8.0,
            backgroundColor: const Color(0xFF8AB4F8),
            child: Icon(fabIcon, size: 24, color: const Color(0xFF131A26)),
          ),
        ),
      ],
    );
  }
}