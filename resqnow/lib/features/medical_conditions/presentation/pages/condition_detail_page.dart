import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/condition_model.dart';
import '../controllers/condition_controller.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/faq_accordion.dart';
import '../widgets/video_player_widget.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';

class ConditionDetailPage extends StatefulWidget {
  final String conditionId;

  const ConditionDetailPage({super.key, required this.conditionId});

  @override
  State<ConditionDetailPage> createState() => _ConditionDetailPageState();
}

class _ConditionDetailPageState extends State<ConditionDetailPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ConditionController controller = ConditionController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;
  bool _isUserInteracting = false;
  late TabController _tabController;
  late TabController _firstAidTabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _firstAidTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCondition(widget.conditionId);
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    // Auto-play disabled - users can swipe manually or use arrow buttons
  }

  void _pauseAutoPlayTemporarily() {
    _isUserInteracting = true;
    Future.delayed(const Duration(seconds: 5), () {
      _isUserInteracting = false;
    });
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
    _tabController.dispose();
    _firstAidTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════════════════
                // HEADER SECTION: Image, Name, Severity, Doctor Type
                // ═══════════════════════════════════════════════════════════
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
                                final path = condition.imageUrls[index]
                                    .replaceFirst('resqnow/lib/', '');
                                if (path.startsWith('http')) {
                                  return CachedNetworkImage(
                                    imageUrl: path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image),
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
                          // Previous image button (left)
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
                                      color: Colors.black.withOpacity(0.4),
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
                          // Next image button (right)
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
                                      color: Colors.black.withOpacity(0.4),
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
                          // Page indicator (bottom)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: _buildPageIndicator(
                              condition.imageUrls.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Header Info Section with action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        condition.name,
                        style: _sectionTitleStyle(context, fontSize: 24),
                      ),
                    ),
                    // Action buttons: Save and Call
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () {},
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

                // Doctor Type Chips
                Wrap(
                  spacing: 8,
                  children: condition.doctorType
                      .map((doc) => Chip(label: Text(doc)))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Severity Indicator
                SeverityIndicator(severity: condition.severity),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // FIRST AID SECTION (NOT IN TABS) - Tabbed Layout
                // ═══════════════════════════════════════════════════════════
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: TabBar(
                    controller: _firstAidTabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: AppColors.primary,
                    isScrollable: false,
                    tabs: const [
                      Tab(text: 'What to Do'),
                      Tab(text: 'What NOT to Do'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TabBarView(
                    controller: _firstAidTabController,
                    children: [
                      // TAB 1: What to Do
                      SingleChildScrollView(
                        child: _buildStepsSection(
                          "What to Do",
                          condition.firstAidDescription,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ),
                      // TAB 2: What NOT to Do
                      SingleChildScrollView(
                        child: _buildStepsSection(
                          "What NOT to Do",
                          condition.doNotDo,
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // TABBED CONTENT SECTION (Resources, Video)
                // ═══════════════════════════════════════════════════════════
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: AppColors.primary,
                    isScrollable: false,
                    tabs: const [
                      Tab(text: 'Resources'),
                      Tab(text: 'Video'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Resources (Required Kits)
                      _buildResourcesTab(condition),

                      // TAB 2: Video
                      _buildVideoTab(condition),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // FAQ SECTION - Link to separate FAQ page
                // ═══════════════════════════════════════════════════════════
                if (condition.faqs.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.help_outline),
                      label: const Text("View Frequently Asked Questions"),
                      onPressed: () {
                        context.push(
                          '/condition/${widget.conditionId}/faqs',
                          extra: condition,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // FOOTER: Find Help Button
                // ═══════════════════════════════════════════════════════════
                if (condition.hospitalLocatorLink.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.local_hospital),
                      label: const Text("Find nearby help"),
                      onPressed: () =>
                          launchUrl(Uri.parse(condition.hospitalLocatorLink)),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 10 : 8,
          height: _currentPage == index ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blue : Colors.grey.shade400,
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: FIRST AID
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFirstAidTab(ConditionModel condition) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepsSection(
            "What to Do",
            condition.firstAidDescription,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 24),
          _buildStepsSection(
            "What NOT to Do",
            condition.doNotDo,
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: RESOURCES - Compact text-only list with navigation indicators
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildResourcesTab(ConditionModel condition) {
    if (condition.requiredKits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "No resources listed",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Required Medical Kits",
            style: _sectionTitleStyle(context, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...condition.requiredKits.map((kit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Text(
                    kit.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  onTap: () {
                    // Navigate to resources page
                    context.push('/resources');
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: VIDEO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVideoTab(ConditionModel condition) {
    if (condition.videoUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              "No video available",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "First Aid Video",
            style: _sectionTitleStyle(context, fontSize: 16),
          ),
          const SizedBox(height: 12),
          VideoPlayerWidget(videoUrl: condition.videoUrl),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: FAQs
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFAQTab(ConditionModel condition) {
    if (condition.faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "No FAQs available",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frequently Asked Questions",
            style: _sectionTitleStyle(context, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ..._buildCompactFAQList(condition.faqs),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPACT FAQ LIST - Text only with direction indicators
  // ═══════════════════════════════════════════════════════════════════════════
  List<Widget> _buildCompactFAQList(List<dynamic> faqs) {
    return List.generate(faqs.length, (index) {
      final faq = faqs[index];
      final question = (faq is Map)
          ? (faq['question'] ?? 'Question')
          : (faq.question ?? 'Question');
      final answer = (faq is Map)
          ? (faq['answer'] ?? 'Answer')
          : (faq.answer ?? 'Answer');

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Q',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'A',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            answer,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSection(
    String title,
    List<String> items, {
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle(context, fontSize: 18)),
        const SizedBox(height: 8),
        ...items.map(
          (step) => ListTile(
            leading: Icon(icon, color: color),
            title: Text(step),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMBERED STEPS SECTION - Optimized for readability
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStepsSection(
    String title,
    List<String> steps, {
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
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
          final isLast = index == steps.length - 1;

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
                      color: color.withOpacity(0.2),
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
                        color: Colors.grey.shade50,
                        border: Border.all(color: color.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
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
}
