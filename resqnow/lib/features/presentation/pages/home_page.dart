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
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_profile_controller.dart';

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
                        hintText: "Search resources, conditions...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
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
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "See All",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
                  color: AppColors.cardShadow.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
            color: AppColors.cardShadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.local_hospital,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 15,
                letterSpacing: -0.3,
              ),
            ),
          ],
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
                  tileType: _BloodTileType.becomeDonor,
                  onTap: () => context.push('/blood-banks'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BloodFeatureTile(
                  title: "Nearby Donors",
                  icon: Icons.people_alt_rounded,
                  tileType: _BloodTileType.myProfile,
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
                  tileType: _BloodTileType.becomeDonor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BloodFeatureTile(
                  title: "My Profile",
                  icon: Icons.person_rounded,
                  tileType: _BloodTileType.myProfile,
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
/// 🩸 BLOOD TILE TYPE ENUM
/// -----------------------------------------------------------
enum _BloodTileType { becomeDonor, myProfile }

/// -----------------------------------------------------------
/// 🩸 BLOOD FEATURE TILE
/// -----------------------------------------------------------
class _BloodFeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final _BloodTileType tileType;
  final VoidCallback? onTap;

  const _BloodFeatureTile({
    required this.title,
    required this.icon,
    required this.tileType,
    this.onTap,
  });

  /// Handle smart navigation based on donor status
  Future<void> _handleTap(BuildContext context) async {
    try {
      final profileController = context.read<DonorProfileController>();
      final isDonor = await profileController.isDonor();

      if (!context.mounted) return;

      if (tileType == _BloodTileType.becomeDonor) {
        // If already donor, show alert and navigate to profile
        if (isDonor) {
          _showAlreadyDonorAlert(context);
        } else {
          // Not a donor, navigate to registration
          context.push('/donor/register');
        }
      } else if (tileType == _BloodTileType.myProfile) {
        // If donor, navigate to profile
        if (isDonor) {
          context.push('/donor/profile');
        } else {
          // Not a donor, show alert and offer to register
          _showNotDonorAlert(context);
        }
      }
    } catch (e) {
      debugPrint("Error handling tile tap: $e");
    }
  }

  /// Alert shown when user tries to view profile but is not a donor
  void _showNotDonorAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Not a Donor Yet',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'You are not registered as a blood donor. Register now to create your donor profile and help save lives!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.push('/donor/register');
            },
            child: const Text('Register Now'),
          ),
        ],
      ),
    );
  }

  /// Alert shown when user is already a donor but clicks "Become a Donor"
  void _showAlreadyDonorAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Already Registered',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'You are already registered as a blood donor! Go to your profile to manage your details and availability.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.push('/donor/profile');
            },
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _handleTap(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _getTileColor(),
          boxShadow: [
            BoxShadow(
              color: _getTileColor().withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor().withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: _getIconColor()),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTileColor() {
    if (tileType == _BloodTileType.becomeDonor) {
      return Colors.red.shade50;
    } else {
      return Colors.blue.shade50;
    }
  }

  Color _getIconColor() {
    if (tileType == _BloodTileType.becomeDonor) {
      return Colors.red.shade600;
    } else {
      return Colors.blue.shade600;
    }
  }
}
