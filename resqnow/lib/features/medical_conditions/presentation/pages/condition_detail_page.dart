import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/condition_model.dart';
import '../controllers/condition_controller.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/video_player_widget.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../saved_topics/data/models/saved_condition_model.dart';
import '../../../saved_topics/data/services/saved_topics_service.dart';

class ConditionDetailPage extends StatefulWidget {
  final String conditionId;

  const ConditionDetailPage({super.key, required this.conditionId});

  @override
  State<ConditionDetailPage> createState() => _ConditionDetailPageState();
}

class _ConditionDetailPageState extends State<ConditionDetailPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ConditionController controller = ConditionController();
  late final SavedTopicsService _savedTopicsService;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;
  bool _isConditionSaved = false;
  final bool _isVideoLoaded = false; // Lazy load video
  final bool _showVideo = false; // Toggle video visibility

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _savedTopicsService = SavedTopicsService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCondition(widget.conditionId);
      _checkIfConditionSaved();
      _startAutoPlay();
    });
  }

  /// Check if the current condition is already saved
  Future<void> _checkIfConditionSaved() async {
    try {
      final isSaved = await _savedTopicsService.isConditionSaved(
        widget.conditionId,
      );
      if (mounted) {
        setState(() {
          _isConditionSaved = isSaved;
        });
      }
    } catch (e) {
      print('⚠️ Error checking if condition is saved: $e');
      // If there's an error, assume not saved
      if (mounted) {
        setState(() {
          _isConditionSaved = false;
        });
      }
    }
  }

  /// Toggle save state
  Future<void> _toggleSaveCondition(ConditionModel condition) async {
    try {
      if (_isConditionSaved) {
        // Delete if already saved
        await _savedTopicsService.deleteCondition(condition.id);
        if (mounted) {
          setState(() => _isConditionSaved = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Condition removed from saved'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Save if not already saved
        final savedCondition = SavedConditionModel.fromCondition(condition);
        await _savedTopicsService.saveCondition(savedCondition);
        if (mounted) {
          setState(() => _isConditionSaved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Condition saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    // Auto-play disabled - users can swipe manually or use arrow buttons
  }

  void _pauseAutoPlayTemporarily() {
    Future.delayed(const Duration(seconds: 5), () {});
  }

  void _goToPreviousImage() {
    if (_pageController.hasClients && controller.condition.value != null) {
      final condition = controller.condition.value!;
      if (condition.imageUrls.isEmpty) return;
      int previousPage = (_currentPage - 1) % condition.imageUrls.length;
      if (previousPage < 0) previousPage += condition.imageUrls.length;
      _pageController.animateToPage(
        previousPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextImage() {
    if (_pageController.hasClients && controller.condition.value != null) {
      final condition = controller.condition.value!;
      if (condition.imageUrls.isEmpty) return;
      int nextPage = (_currentPage + 1) % condition.imageUrls.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: null,
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final ConditionModel? condition = controller.condition.value;
          if (condition == null) {
            return const Center(child: Text("No data found"));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ═══════════════════════════════════════════════════════════
                    // HEADER SECTION - Wrapped in RepaintBoundary
                    // ═══════════════════════════════════════════════════════════
                    RepaintBoundary(
                      child: _buildHeaderSection(condition, isDarkMode),
                    ),

                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════════════════════════
                    // FIRST AID SECTION - Wrapped in RepaintBoundary
                    // ═══════════════════════════════════════════════════════════
                    RepaintBoundary(child: _buildFirstAidSection(condition)),

                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════════════════════════
                    // VIDEO SECTION - Lazy loaded with RepaintBoundary
                    // ═══════════════════════════════════════════════════════════
                    if (condition.videoUrl.isNotEmpty)
                      RepaintBoundary(
                        child: _buildVideoSection(condition, isDarkMode),
                      )
                    else
                      RepaintBoundary(child: _buildNoVideoSection(isDarkMode)),

                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════════════════════════
                    // QUICK ACCESS CARDS - Wrapped in RepaintBoundary
                    // ═══════════════════════════════════════════════════════════
                    RepaintBoundary(
                      child: _buildExploreMoreSection(condition, isDarkMode),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ConditionModel condition, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Carousel
        if (condition.imageUrls.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (_) => _pauseAutoPlayTemporarily(),
                    onPanDown: (_) => _pauseAutoPlayTemporarily(),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: condition.imageUrls.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final path = condition.imageUrls[index].replaceFirst(
                          'resqnow/lib/',
                          '',
                        );
                        if (path.startsWith('http')) {
                          return CachedNetworkImage(
                            imageUrl: path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                            memCacheHeight: 250,
                            memCacheWidth: 500,
                          );
                        } else {
                          return Image.asset(
                            path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }
                      },
                    ),
                  ),
                  // Previous image button
                  if (condition.imageUrls.length > 1)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _goToPreviousImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Next image button
                  if (condition.imageUrls.length > 1)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _goToNextImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Page indicator
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: _buildPageIndicator(condition.imageUrls.length),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Header info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                condition.name,
                style: _sectionTitleStyle(context, fontSize: 24),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isConditionSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isConditionSaved ? AppColors.primary : null,
                  ),
                  onPressed: () => _toggleSaveCondition(condition),
                  tooltip: _isConditionSaved
                      ? 'Remove from saved'
                      : 'Save condition',
                ),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => context.push('/emergency-numbers'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Doctor type chips
        Wrap(
          spacing: 8,
          children: condition.doctorType
              .map((doc) => Chip(label: Text(doc)))
              .toList(),
        ),

        const SizedBox(height: 12),

        // Severity indicator
        SeverityIndicator(severity: condition.severity),
      ],
    );
  }

  Widget _buildFirstAidSection(ConditionModel condition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // What to Do
        _buildStepsSection(
          "What to Do",
          condition.firstAidDescription,
          color: Colors.green,
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildVideoSection(ConditionModel condition, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Aid Video',
          style: _sectionTitleStyle(context, fontSize: 18),
        ),
        const SizedBox(height: 16),
        VideoPlayerWidget(videoUrl: condition.videoUrl),
      ],
    );
  }

  Widget _buildNoVideoSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Aid Video',
          style: _sectionTitleStyle(context, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 48,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No video available',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMoreSection(ConditionModel condition, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore More', style: _sectionTitleStyle(context, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: [
            // Resources Card
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.medical_services,
                iconColor: Colors.blue,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                label: 'Resources',
                onTap: () => context.push('/resources'),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),

            // FAQ Card
            if (condition.faqs.isNotEmpty)
              Expanded(
                child: _buildQuickAccessCard(
                  icon: Icons.help_outline,
                  iconColor: Colors.orange,
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  label: 'FAQs',
                  onTap: () {
                    context.push(
                      '/categories/condition/${widget.conditionId}/faqs',
                      extra: condition,
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
              ),

            const SizedBox(width: 12),

            // Hospital Card
            if (condition.hospitalLocatorLink.isNotEmpty)
              Expanded(
                child: _buildQuickAccessCard(
                  icon: Icons.local_hospital,
                  iconColor: Colors.red,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  label: 'Hospitals',
                  onTap: () =>
                      launchUrl(Uri.parse(condition.hospitalLocatorLink)),
                  isDarkMode: isDarkMode,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 10 : 8,
          height: _currentPage == index ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.primary
                : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: FIRST AID
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMBERED STEPS SECTION - Optimized for readability
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStepsSection(
    String title,
    List<String> steps, {
    required Color color,
    required IconData icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: _sectionTitleStyle(
                  context,
                  fontSize: 18,
                ).copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Steps in numbered cards
        ...List.generate(steps.length, (index) {
          final stepNumber = index + 1;
          final step = steps[index];

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: isDarkMode ? 0.25 : 0.2),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Step content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: color.withValues(
                            alpha: isDarkMode ? 0.3 : 0.2,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // No connector line - steps are visually connected through proximity
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context, {double? fontSize}) {
    final baseStyle = AppTextStyles.sectionTitle;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return baseStyle.copyWith(
      fontSize: fontSize ?? baseStyle.fontSize,
      color: isDark ? Colors.white : (baseStyle.color ?? AppColors.textPrimary),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ACCESS CARD BUILDER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
