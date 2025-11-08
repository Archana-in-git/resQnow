import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) onTap!(index);
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            // Direct Explore (magnifier) to the category list page
            context.go('/categories');
            break;
          case 2:
            context.go('/emergency-numbers');
            break;
          case 3:
            context.go('/resources');
            break;
          case 4:
            context.go('/user-profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.call_rounded),
          label: 'Emergency',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_rounded),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
