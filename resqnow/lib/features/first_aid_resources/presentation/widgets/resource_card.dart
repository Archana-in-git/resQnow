import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/domain/entities/resource.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                resource.imageUrls.isNotEmpty
                    ? resource.imageUrls.first
                    : 'https://via.placeholder.com/150',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Name + Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Resource Name
                  Expanded(
                    child: Text(
                      resource.name,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Action Icon (circle button)
                  GestureDetector(
                    onTap: onActionTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
