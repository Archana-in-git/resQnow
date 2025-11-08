import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/condition_model.dart';
import '../controllers/condition_controller.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/required_kits_list.dart';
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
    with AutomaticKeepAliveClientMixin {
  final ConditionController controller = ConditionController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;
  bool _isUserInteracting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCondition(widget.conditionId);
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final condition = controller.condition.value;
      if (!_isUserInteracting &&
          _pageController.hasClients &&
          condition != null &&
          condition.imageUrls.isNotEmpty) {
        int nextPage = (_currentPage + 1) % condition.imageUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseAutoPlayTemporarily() {
    _isUserInteracting = true;
    Future.delayed(const Duration(seconds: 5), () {
      _isUserInteracting = false;
    });
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => context.push('/emergency-numbers'),
          ),
        ],
      ),
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
                if (condition.imageUrls.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 220,
                      child: GestureDetector(
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPageIndicator(condition.imageUrls.length),
                  const SizedBox(height: 16),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        condition.name,
                        style: _sectionTitleStyle(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: condition.doctorType
                      .map((doc) => Chip(label: Text(doc)))
                      .toList(),
                ),

                const SizedBox(height: 16),

                SeverityIndicator(severity: condition.severity),

                const SizedBox(height: 20),

                _buildSection(
                  "What to Do",
                  condition.firstAidDescription,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),

                _buildSection(
                  "What NOT to Do",
                  condition.doNotDo,
                  icon: Icons.cancel,
                  color: Colors.red,
                ),

                if (condition.videoUrl.isNotEmpty) ...[
                  Text(
                    "First Aid Video",
                    style: _sectionTitleStyle(context, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  VideoPlayerWidget(videoUrl: condition.videoUrl),
                  const SizedBox(height: 16),
                ],

                if (condition.requiredKits.isNotEmpty) ...[
                  Text(
                    "Required Medical Kits",
                    style: _sectionTitleStyle(context, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  RequiredKitsList(kits: condition.requiredKits),
                  const SizedBox(height: 16),
                ],

                if (condition.faqs.isNotEmpty) ...[
                  Text(
                    "FAQs",
                    style: _sectionTitleStyle(context, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  FAQAccordion(faqs: condition.faqs),
                  const SizedBox(height: 16),
                ],

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

  TextStyle _sectionTitleStyle(BuildContext context, {double? fontSize}) {
    final baseStyle = AppTextStyles.sectionTitle;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return baseStyle.copyWith(
      fontSize: fontSize ?? baseStyle.fontSize,
      color: isDark ? Colors.white : (baseStyle.color ?? AppColors.textPrimary),
    );
  }
}
