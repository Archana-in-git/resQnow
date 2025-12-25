import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/condition_model.dart';
import '../controllers/condition_controller.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';

class ConditionFAQPage extends StatefulWidget {
  final String conditionId;
  final ConditionModel? condition;

  const ConditionFAQPage({
    super.key,
    required this.conditionId,
    this.condition,
  });

  @override
  State<ConditionFAQPage> createState() => _ConditionFAQPageState();
}

class _ConditionFAQPageState extends State<ConditionFAQPage> {
  final ConditionController controller = ConditionController();
  late ConditionModel? _condition;

  @override
  void initState() {
    super.initState();
    _condition = widget.condition;
    if (_condition == null) {
      controller.fetchCondition(widget.conditionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _condition?.name ?? 'FAQs',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _condition != null
          ? _buildFAQContent(_condition!)
          : ValueListenableBuilder<ConditionModel?>(
              valueListenable: controller.condition,
              builder: (context, condition, _) {
                if (condition == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildFAQContent(condition);
              },
            ),
    );
  }

  Widget _buildFAQContent(ConditionModel condition) {
    if (condition.faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No FAQs available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ..._buildFAQList(condition.faqs),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildFAQList(List<dynamic> faqs) {
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
                    maxLines: 3,
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
}
