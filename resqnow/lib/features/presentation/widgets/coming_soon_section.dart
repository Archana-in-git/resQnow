import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/core/constants/ui_constants.dart';

/// 🧱 A simple reusable Coming Soon section card.
class ComingSoonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ComingSoonCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: UIConstants.cardMarginVertical,
        horizontal: UIConstants.screenPadding,
      ),
      padding: const EdgeInsets.all(UIConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
