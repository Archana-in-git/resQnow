import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/ui_constants.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/features/home/presentation/widgets/category_carousel.dart';
import 'package:resqnow/features/home/presentation/widgets/nearby_hospitals.dart';
import 'package:resqnow/features/home/presentation/widgets/search_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(UIConstants.appBarHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.screenPadding,
          ),
          child: AppBar(
            backgroundColor: AppColors.primary,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Placeholder
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Your Location',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Notification Icon with TODO
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // TODO: Link to notification page when created
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: UIConstants.widgetSpacing),
            CustomSearchBar(),
            SizedBox(height: UIConstants.cardMarginVertical),
            CategoryCarousel(),
            SizedBox(height: UIConstants.cardMarginVertical),
            NearbyHospitalsSection(),
            SizedBox(height: 80), // To avoid FAB overlap
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement AI Chatbot Action
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.chat_bubble_outline),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Add navigation logic later
        },
      ),
    );
  }
}
