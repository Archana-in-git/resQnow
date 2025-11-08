import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SeverityIndicator extends StatelessWidget {
  final String severity; // low | medium | high | critical

  const SeverityIndicator({super.key, required this.severity});

  Color _getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.success; // Green
      case 'medium':
        return AppColors.warning; // Amber
      case 'high':
        return Colors.orange; // Orange
      case 'critical':
        return AppColors.accent; // Red
      default:
        return AppColors.textSecondary; // fallback gray
    }
  }

  String _getSeverityLabel() {
    switch (severity.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();
    final label = _getSeverityLabel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity: $label',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 224, 224, 224),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _severityToValue(),
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  double _severityToValue() {
    switch (severity.toLowerCase()) {
      case 'low':
        return 0.25;
      case 'medium':
        return 0.5;
      case 'high':
        return 0.75;
      case 'critical':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
