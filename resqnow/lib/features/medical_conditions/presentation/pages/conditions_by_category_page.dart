import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/condition_model.dart';
import '../../data/services/condition_service.dart';
import '../../../../core/constants/app_colors.dart';

/// Page to display all conditions for a specific category
class ConditionsByCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ConditionsByCategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ConditionsByCategoryPage> createState() => _ConditionsByCategoryPageState();
}

class _ConditionsByCategoryPageState extends State<ConditionsByCategoryPage> {
  final ConditionService _conditionService = ConditionService();
  List<ConditionModel> _conditions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conditions = await _conditionService.getConditionsByCategory(widget.categoryId);
      if (mounted) {
        setState(() {
          _conditions = conditions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConditions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_conditions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No conditions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No medical conditions available for this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        final condition = _conditions[index];
        return _buildConditionCard(condition, isDarkMode);
      },
    );
  }

  Widget _buildConditionCard(ConditionModel condition, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/categories/condition/${condition.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Condition Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: condition.imageUrls.isNotEmpty
                    ? _buildConditionImage(condition.imageUrls.first)
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Condition Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSeverityChip(condition.severity),
                    const SizedBox(height: 4),
                    if (condition.firstAidDescription.isNotEmpty)
                      Text(
                        condition.firstAidDescription.first.length > 80
                            ? '${condition.firstAidDescription.first.substring(0, 80)}...'
                            : condition.firstAidDescription.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionImage(String imageUrl) {
    // Check if it's a network URL or local asset
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.grey[400]),
        ),
      );
    } else {
      // Local asset
      final filename = imageUrl.contains('/') ? imageUrl.split('/').last : imageUrl;
      final assetPath = 'lib/assets/images/firstaid_images/$filename';
      return Image.asset(
        assetPath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.grey[400]),
        ),
      );
    }
  }

  Widget _buildSeverityChip(String severity) {
    Color chipColor;
    switch (severity.toLowerCase()) {
      case 'critical':
        chipColor = Colors.red;
        break;
      case 'high':
        chipColor = Colors.orange;
        break;
      case 'medium':
        chipColor = Colors.yellow.shade700;
        break;
      default:
        chipColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
