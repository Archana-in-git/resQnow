import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/ui_constants.dart';
import 'package:resqnow/features/presentation/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: const ResQNowNavBar(),

      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
          // Previous gradient background:
          // gradient: isDarkMode
          //     ? LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [
          //           Colors.grey.shade900,
          //           Colors.grey.shade800,
          //           Colors.grey.shade900,
          //         ],
          //       )
          //     : LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [
          //           Colors.blue.shade50,
          //           Colors.teal.shade50,
          //           Colors.blue.shade50,
          //         ],
          //       ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(UIConstants.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Top Bar
                const TopBar(),
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
                          fillColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
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
                            color: AppColors.primary.withValues(alpha: 0.2),
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

                /// 🔹 Emergency Numbers
                _buildSectionHeader(
                  title: "Emergency Numbers",
                  onSeeAll: () => context.push('/emergency-numbers'),
                ),
                const SizedBox(height: 12),

                const _EmergencyNumbersSection(),

                const SizedBox(height: 24),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(kit.name)),
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
                GestureDetector(
                  onTap: () => context.push('/workshops'),
                  child: const _ComingSoonCard(title: "Coming Soon"),
                ),
              ],
            ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black26
                      : AppColors.cardShadow.withValues(alpha: 0.1),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : AppColors.cardShadow.withValues(alpha: 0.1),
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
                colors: isDarkMode
                    ? [Colors.grey.shade700, Colors.grey.shade800]
                    : [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.08),
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : AppColors.cardShadow.withValues(alpha: 0.08),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
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
/// 🩸 BLOOD BANK & DONOR FOUR-TILE SECTION
/// -----------------------------------------------------------
class _BloodBankHomeSection extends StatelessWidget {
  const _BloodBankHomeSection();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final tiles = [
      {
        'title': 'Blood Banks',
        'icon': Icons.local_hospital_rounded,
        'color': Colors.red,
        'route': '/blood-banks',
      },
      {
        'title': 'Find Donors',
        'icon': Icons.people_alt_rounded,
        'color': Colors.blue,
        'route': '/donors',
      },
      {
        'title': 'Become Donor',
        'icon': Icons.volunteer_activism_rounded,
        'color': Colors.orange,
        'route': null,
      },
      {
        'title': 'My Profile',
        'icon': Icons.person_rounded,
        'color': Colors.purple,
        'route': null,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: List.generate(tiles.length, (index) {
        final tile = tiles[index];
        return _BloodTile(
          title: tile['title'] as String,
          icon: tile['icon'] as IconData,
          color: tile['color'] as Color,
          route: tile['route'] as String?,
          isDarkMode: isDarkMode,
        );
      }),
    );
  }
}

/// -----------------------------------------------------------
/// 🩸 BLOOD TILE WIDGET
/// -----------------------------------------------------------
class _BloodTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  final bool isDarkMode;

  const _BloodTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.isDarkMode,
  });

  void _handleTap(BuildContext context) {
    if (route != null) {
      context.push(route!);
    } else {
      // For non-clickable tiles or smart navigation
      if (title == 'Become Donor') {
        try {
          final profileController = context.read<DonorProfileController>();
          profileController.isDonor().then((isDonor) {
            if (isDonor) {
              // Show alert if already a donor
              _showAlreadyDonorAlert(context);
            } else {
              context.push('/donor/register');
            }
          });
        } catch (e) {
          debugPrint("Error: $e");
        }
      } else if (title == 'My Profile') {
        // Always navigate to donor profile page
        // The page will handle showing dialog if user is not a donor
        context.push('/donor/profile');
      }
    }
  }

  void _showAlreadyDonorAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Already a Donor',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'You are already registered as a blood donor. Visit your profile to manage your details and availability.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/donor/profile');
            },
            child: const Text(
              'View Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black26
                  : AppColors.cardShadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with colored background
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------
/// 🚨 EMERGENCY NUMBERS SECTION (REDESIGNED - ROUNDED ICONS)
/// -----------------------------------------------------------
class _EmergencyNumbersSection extends StatelessWidget {
  const _EmergencyNumbersSection();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final services = [
      {
        'number': '102',
        'icon': Icons.local_hospital_rounded,
        'color': Colors.red,
      },
      {'number': '100', 'icon': Icons.security_rounded, 'color': Colors.blue},
      {
        'number': '101',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange,
      },
      {'number': '108', 'icon': Icons.warning_rounded, 'color': Colors.purple},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final service = services[index];
          return _EmergencyIconButton(
            number: service['number'] as String,
            icon: service['icon'] as IconData,
            color: service['color'] as Color,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}

/// -----------------------------------------------------------
/// 🚨 EMERGENCY ICON BUTTON (ROUNDED)
/// -----------------------------------------------------------
class _EmergencyIconButton extends StatefulWidget {
  final String number;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const _EmergencyIconButton({
    required this.number,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  State<_EmergencyIconButton> createState() => _EmergencyIconButtonState();
}

class _EmergencyIconButtonState extends State<_EmergencyIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) => _controller.reverse());
  }

  Future<void> _makePhoneCall(String number) async {
    try {
      debugPrint('Calling: $number');
    } catch (e) {
      debugPrint("Error calling: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 0.88,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: GestureDetector(
        onTapDown: (_) => _handlePress(),
        onTapUp: (_) => _makePhoneCall(widget.number),
        child: Container(
          width: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 28),
              const SizedBox(height: 4),
              Text(
                widget.number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
