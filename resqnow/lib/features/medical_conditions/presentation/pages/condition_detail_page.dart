import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/condition_model.dart';
import '../controllers/condition_controller.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/required_kits_list.dart';
import '../widgets/faq_accordion.dart';
import '../widgets/video_player_widget.dart';
import '../../../../core/constants/app_text_styles.dart';

class ConditionDetailPage extends StatelessWidget {
  final String conditionId;

  ConditionDetailPage({super.key, required this.conditionId});

  final ConditionController controller = Get.put(ConditionController());

  @override
  Widget build(BuildContext context) {
    // Fetch after first frame to avoid calling during build repeatedly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCondition(conditionId);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox.shrink(), // as per design (no title here)
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => Get.toNamed('/emergency-numbers'),
          ),
        ],
      ),
      body: Obx(() {
        // NOTE: controller uses Rx types (isLoading and condition). Access .value here.
        if (controller.isLoading.value) {
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
              // Image carousel (simple single image shown here)
              if (condition.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    condition.imageUrls.first,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),

              // Condition Name + Save icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      condition.name,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Doctor Type chips
              Wrap(
                spacing: 8,
                children: condition.doctorType
                    .map((doc) => Chip(label: Text(doc)))
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Severity Indicator
              SeverityIndicator(severity: condition.severity),

              const SizedBox(height: 20),

              // What to Do (firstAidDescription)
              Text(
                "What to Do",
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...condition.firstAidDescription.map(
                (step) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(step),
                ),
              ),

              const SizedBox(height: 16),

              // What Not to Do
              Text(
                "What NOT to Do",
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...condition.doNotDo.map(
                (item) => ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: Text(item),
                ),
              ),

              const SizedBox(height: 16),

              // Video
              if (condition.videoUrl.isNotEmpty) ...[
                Text(
                  "First Aid Video",
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                VideoPlayerWidget(videoUrl: condition.videoUrl),
                const SizedBox(height: 16),
              ],

              // Required Kits (pass model list directly)
              if (condition.requiredKits.isNotEmpty) ...[
                Text(
                  "Required Medical Kits",
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                RequiredKitsList(kits: condition.requiredKits),
                const SizedBox(height: 16),
              ],

              // FAQs
              if (condition.faqs.isNotEmpty) ...[
                Text(
                  "FAQs",
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                FAQAccordion(faqs: condition.faqs),
                const SizedBox(height: 16),
              ],

              // Hospital Locator CTA
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
      }),
    );
  }
}
