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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Container(
          margin: EdgeInsets.only(
            left: 50, 
            right: 50, 
            bottom: 10 + bottomPadding, 
            top: 8
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            // --- ADJUST SHADOW HERE ---
            boxShadow: [
              
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0), 
              child: Container(
                // --- ADJUST HEIGHT HERE ---
                // Tweaking vertical padding changes the thickness of the bar
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2230).withValues(alpha: 0.55), // Slightly darker tint
                  borderRadius: BorderRadius.circular(40),
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
          // --- ADJUST ITEM HEIGHT HERE ---
          // This padding also affects the overall height of the bar
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: isSelected
              ? BoxDecoration(
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 24, // Slightly smaller icon to match tighter padding
                    color: isSelected
                        ? const Color(0xFFE8F0FE)
                        : Colors.white.withValues(alpha: 0.6),
                  ),
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
                            color: Colors.white.withValues(alpha: 0.2), 
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
              const SizedBox(height: 4), // Reduced spacing
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? const Color(0xFFE8F0FE)
                      : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11, // Slightly smaller text
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
          // Adjust this if the FAB overlaps the pill after height adjustments
          bottom: 105 + bottomPadding, 
          child: FloatingActionButton(
            onPressed: onFABPressed,
            tooltip: fabTooltip,
            elevation: 6.0,
            backgroundColor: const Color(0xFF8AB4F8),
            child: Icon(fabIcon, size: 24, color: const Color(0xFF131A26)),
          ),
        ),
      ],
    );
  }
}