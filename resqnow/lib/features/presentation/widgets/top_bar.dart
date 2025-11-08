// top_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/core/constants/app_colors.dart';

class TopBar extends StatelessWidget {
  final String locationText;

  const TopBar({super.key, required this.locationText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              locationText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        InkWell(
          onTap: () {
            context.push('/notifications');
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notifications_none, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
