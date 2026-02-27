// category_card.dart

import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  /// Check if the path is a network URL
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Transform asset path from filename to full asset path
  /// Admin stores just filename (e.g., "lungs-organ.png")
  /// Main app needs full path (e.g., "lib/assets/images/icons/lungs-organ.png")
  String _transformAssetPath(String filename) {
    if (filename.isEmpty) return '';
    if (_isNetworkUrl(filename)) return filename; // Return URLs as-is
    // Handle full paths - extract just the filename
    final justFilename = filename.contains('/')
        ? filename.split('/').last
        : filename;
    // Replace spaces with underscores (consistent with admin app)
    final normalized = justFilename.replaceAll(' ', '_');
    return 'lib/assets/images/icons/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _buildCategoryImage(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: AppTextStyles.cardTitle.copyWith(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build category image with priority: imageUrls > iconAsset
  Widget _buildCategoryImage() {
    // Priority 1: Use imageUrls if available
    if (category.imageUrls.isNotEmpty) {
      return Image.network(
        category.imageUrls.first,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[600],
              size: 32,
            ),
          );
        },
      );
    }

    // Priority 2: Use iconAsset (could be local file or URL)
    if (category.iconAsset.isEmpty) {
      return Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: 32,
      );
    }

    return _isNetworkUrl(category.iconAsset)
        ? Image.network(
            category.iconAsset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 32,
                ),
              );
            },
          )
        : Image.asset(
            _transformAssetPath(category.iconAsset),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 32,
                ),
              );
            },
          );
  }
}
