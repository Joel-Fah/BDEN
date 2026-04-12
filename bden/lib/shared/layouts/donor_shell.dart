import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/app_colors.dart';

class DonorShell extends StatelessWidget {
  final Widget child;
  const DonorShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          _onItemTapped(0, context);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          destinations: const [
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: AppColors.textSecondary),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: AppColors.primary),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDroplet,
                  color: AppColors.textSecondary),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDroplet,
                  color: AppColors.primary),
              label: 'Pledges',
            ),
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  color: AppColors.textSecondary),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  color: AppColors.primary),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppColors.textSecondary),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home/feed')) {
      return 0;
    }
    if (location.startsWith('/home/pledges')) {
      return 1;
    }
    if (location.startsWith('/home/notifications')) {
      return 2;
    }
    if (location.startsWith('/home/profile') ||
        location.startsWith('/home/cards') ||
        location.startsWith('/home/myths')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/feed');
        break;
      case 1:
        context.go('/home/pledges');
        break;
      case 2:
        context.go('/home/notifications');
        break;
      case 3:
        context.go('/home/profile');
        break;
    }
  }
}
