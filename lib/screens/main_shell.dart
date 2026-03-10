import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static int _calculateIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/devices')) return 1;
    if (location.startsWith('/dosage-history')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _calculateIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false, // Bottom is handled by the nav bar + system
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFE2E8F0),
              width: 0.5,
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index != currentIndex) {
                  HapticFeedback.selectionClick();
                }
                switch (index) {
                  case 0:
                    context.go('/dashboard');
                  case 1:
                    context.go('/devices');
                  case 2:
                    context.go('/dosage-history');
                  case 3:
                    context.go('/settings');
                }
              },
              items: [
                _buildNavItem(
                  Icons.dashboard_outlined,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  currentIndex == 0,
                ),
                _buildNavItem(
                  Icons.devices_outlined,
                  Icons.devices_rounded,
                  'Devices',
                  currentIndex == 1,
                ),
                _buildNavItem(
                  Icons.history_outlined,
                  Icons.history_rounded,
                  'History',
                  currentIndex == 2,
                ),
                _buildNavItem(
                  Icons.settings_outlined,
                  Icons.settings_rounded,
                  'Settings',
                  currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    bool isActive,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: isActive ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Icon(inactiveIcon),
      ),
      activeIcon: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
