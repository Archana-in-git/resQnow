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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<LocationController>().initialize();

      final categoryController = context.read<CategoryController>();
      if (categoryController.categories.isEmpty) {
        categoryController.loadCategories();
      }

      final resourceController = context.read<ResourceController>();
      if (resourceController.resources.isEmpty &&
          !resourceController.isLoading) {
        await resourceController.fetchResources();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationText = context.watch<LocationController>().locationText;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const ResQNowNavBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(UIConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Top Bar
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

              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final width = constraints.maxWidth;
                  final diameter = (width - (spacing * 3)) / 4;

                  final categories = context
                      .watch<CategoryController>()
                      .categories
                      .take(6)
                      .toList();

                  return SizedBox(
                    height: diameter,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: spacing),
                      itemBuilder: (_, index) {
                        final cat = categories[index];
                        return _CategoryCircleIcon(
                          diameter: diameter,
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
                  itemBuilder: (_, index) =>
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

              Builder(
                builder: (context) {
                  final ctrl = context.watch<ResourceController>();

                  if (ctrl.isLoading) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (ctrl.error != null) {
                    return SizedBox(
                      height: 140,
                      child: Center(child: Text('Error: ${ctrl.error}')),
                    );
                  }

                  final kits = ctrl.resources.take(4).toList();

                  if (kits.isEmpty) {
                    return const _ComingSoonCard(title: "Coming Soon");
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kits.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final kit = kits[index];
                        return SizedBox(
                          width: 180,
                          child: ResourceCard(
                            resource: kit,
                            onTap: () =>
                                context.push('/resource-detail', extra: kit),
                            onActionTap: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(kit.name)));
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // -----------------------------------------------------
              // 🔥 NEW: BLOOD BANK & DONOR GRID ADDED HERE
              // -----------------------------------------------------
              _buildSectionHeader(title: "Blood Banks & Donors"),
              const SizedBox(height: 12),
              const _BloodBankHomeSection(),
              const SizedBox(height: 24),
              // -----------------------------------------------------

              /// 🔹 Workshops
              _buildSectionHeader(title: "Workshops"),
              const SizedBox(height: 12),
              const _ComingSoonCard(title: "Coming Soon"),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),

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

/// -----------------------------------------------------------
/// 🔵 Category Circle Icon
/// -----------------------------------------------------------
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
                  ? Image.asset(iconPath, fit: BoxFit.contain)
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

/// -----------------------------------------------------------
/// 🏥 Hospital Card Placeholder
/// -----------------------------------------------------------
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
              color: AppColors.primary.withValues(alpha: 0.2),
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

/// -----------------------------------------------------------
/// 🟥 Coming Soon Card
/// -----------------------------------------------------------
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

/// -----------------------------------------------------------
/// 🩸 BLOOD BANK & DONOR GRID SECTION (NEW)
/// -----------------------------------------------------------
class _BloodBankHomeSection extends StatelessWidget {
  const _BloodBankHomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Expanded(
                child: _BloodFeatureTile(
                  title: "Blood Banks",
                  icon: Icons.local_hospital_rounded,
                  onTap: () => context.push('/blood-banks'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BloodFeatureTile(
                  title: "Nearby Donors",
                  icon: Icons.people_alt_rounded,
                  onTap: () => context.push('/donors'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BloodFeatureTile(
                  title: "Become a Donor",
                  icon: Icons.volunteer_activism_rounded,
                  onTap: () => context.push('/donor/register'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------
/// 🩸 BLOOD FEATURE TILE
/// -----------------------------------------------------------
class _BloodFeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BloodFeatureTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
