import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/ui_constants.dart';
import 'package:resqnow/features/presentation/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:resqnow/features/presentation/controllers/location_controller.dart';
import 'package:resqnow/features/presentation/widgets/top_bar.dart';
import 'package:resqnow/features/condition_categories/presentation/controllers/category_controller.dart';
import 'package:resqnow/features/first_aid_resources/presentation/controllers/resource_controller.dart';
import 'package:resqnow/features/first_aid_resources/presentation/widgets/resource_card.dart';
import 'package:resqnow/features/presentation/widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ Key to control the Scaffold for opening drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryController>().loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final locationText = context.watch<LocationController>().locationText;

    return Scaffold(
      key: _scaffoldKey, // ✅ Add key
      backgroundColor: AppColors.background,

      // ✅ Add endDrawer for right-to-left opening
      endDrawer: const ResQNowNavBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Top Bar with dynamic location
              TopBar(locationText: locationText),

              const SizedBox(height: 20),

              /// 🔹 Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ✅ Replaced filter icon with menu icon
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔹 First Aid Categories
              _buildSectionHeader(
                title: "First Aid Categories",
                onSeeAll: () => context.push('/categories'),
              ),
              const SizedBox(height: 12),
              // Rounded category icons (no labels). Show up to 6 (4 visible, horizontal scroll to reveal 2)
              LayoutBuilder(
                builder: (context, constraints) {
                  const itemSpacing = 12.0;
                  final availableWidth = constraints.maxWidth;
                  // diameter so 4 circles fit across with spacing
                  final circleDiameter =
                      (availableWidth - (itemSpacing * 3)) / 4;

                  final categories = context
                      .watch<CategoryController>()
                      .categories
                      .take(6)
                      .toList();

                  return SizedBox(
                    height: circleDiameter,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: itemSpacing),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return _CategoryCircleIcon(
                          diameter: circleDiameter,
                          iconPath: cat.iconAsset,
                          onTap: () =>
                              context.push('/categories/condition/${cat.id}'),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              /// 🔹 Nearby Hospitals
              _buildSectionHeader(
                title: "Nearby Hospitals",
                onSeeAll: () => context.push('/hospitals'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) =>
                      _HospitalCardPlaceholder(name: "Hospital ${index + 1}"),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 First Aid Kits
              _buildSectionHeader(
                title: "First Aid Kits",
                onSeeAll: () => context.push('/resources'),
              ),
              const SizedBox(height: 12),
              // Show actual first-aid kit resources (up to 4) fetched from ResourceController.
              Builder(
                builder: (context) {
                  final controller = context.watch<ResourceController>();

                  if (controller.isLoading) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.error != null) {
                    return SizedBox(
                      height: 140,
                      child: Center(child: Text('Error: ${controller.error}')),
                    );
                  }

                  final kits = controller.resources.take(4).toList();

                  if (kits.isEmpty) {
                    return _ComingSoonCard(title: "Coming Soon");
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kits.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final kit = kits[index];
                        return SizedBox(
                          width: 180,
                          child: ResourceCard(
                            resource: kit,
                            onTap: () {
                              // Navigate to resource detail - adjust route if different
                              context.push('/resource/${kit.id}');
                            },
                            onActionTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${kit.name}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              /// 🔹 Blood Banks & Donors
              _buildSectionHeader(title: "Blood Banks & Donors"),
              const SizedBox(height: 12),
              _ComingSoonCard(title: "Coming Soon"),

              const SizedBox(height: 24),

              /// 🔹 Learn First Aid / Workshops
              _buildSectionHeader(title: "Workshops"),
              const SizedBox(height: 12),
              _ComingSoonCard(title: "Coming Soon"),
            ],
          ),
        ),
      ),

      /// 🔹 Bottom Navigation Bar
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),

      /// 🔹 Floating AI Chat Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push('/ai-chat-coming-soon'),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "See All",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// 🔵 Category Circle Icon (no label)
class _CategoryCircleIcon extends StatelessWidget {
  final double diameter;
  final String iconPath;
  final VoidCallback? onTap;

  const _CategoryCircleIcon({
    required this.diameter,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final innerSize = diameter * 0.8;
    final padding = (diameter - innerSize) / 2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: diameter,
        child: Center(
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: iconPath.isNotEmpty
                  ? Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(
                        Icons.medical_information,
                        color: AppColors.primary,
                        size: innerSize * 0.5,
                      ),
                    )
                  : Icon(
                      Icons.medical_information,
                      color: AppColors.primary,
                      size: innerSize * 0.5,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🏥 Placeholder: Hospital Card
class _HospitalCardPlaceholder extends StatelessWidget {
  final String name;
  const _HospitalCardPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.local_hospital,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🟥 Coming Soon Card
class _ComingSoonCard extends StatelessWidget {
  final String title;
  const _ComingSoonCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
