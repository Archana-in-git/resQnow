import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/domain/entities/resource.dart';

class ResourceDetailPage extends StatelessWidget {
  final Resource resource;

  const ResourceDetailPage({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(resource.name, style: AppTextStyles.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: AppColors.primary),
            onPressed: () {
              // TODO: Implement save to topics
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${resource.name} saved!")),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel (simple PageView)
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: resource.imageUrls.isNotEmpty
                    ? resource.imageUrls.length
                    : 1,
                itemBuilder: (context, index) {
                  final imageUrl = resource.imageUrls.isNotEmpty
                      ? resource.imageUrls[index]
                      : 'https://via.placeholder.com/400';

                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Resource Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(resource.name, style: AppTextStyles.sectionTitle),
            ),

            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(resource.description, style: AppTextStyles.bodyText),
            ),

            const SizedBox(height: 16),

            // Categories
            if (resource.category.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: resource.category
                      .map(
                        (cat) => Chip(
                          label: Text(cat),
                          backgroundColor: AppColors.primary.withAlpha(
                            (0.1 * 255).toInt(),
                          ),
                          labelStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 8),

            // Tags
            if (resource.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: resource.tags
                      .map(
                        (tag) => Chip(
                          label: Text("#$tag"),
                          backgroundColor: AppColors.textSecondary.withAlpha(
                            (0.1 * 255).toInt(),
                          ),
                          labelStyle: AppTextStyles.caption,
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
