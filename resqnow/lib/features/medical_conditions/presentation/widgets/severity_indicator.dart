import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SeverityIndicator extends StatefulWidget {
  final String severity; // low | medium | high | critical

  const SeverityIndicator({super.key, required this.severity});

  @override
  State<SeverityIndicator> createState() => _SeverityIndicatorState();
}

class _SeverityIndicatorState extends State<SeverityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final targetValue = _severityToValue(widget.severity);
    _fillAnimation = Tween<double>(begin: 0.0, end: targetValue).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(SeverityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.severity != widget.severity) {
      _animationController.dispose();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(double animationValue) {
    // Determine color based on animation progress
    if (animationValue <= 0.25) {
      // Green (Low)
      return AppColors.success;
    } else if (animationValue <= 0.5) {
      // Transition from Green to Yellow (Medium)
      final t = (animationValue - 0.25) / 0.25;
      return Color.lerp(AppColors.success, Colors.yellow, t) ??
          AppColors.success;
    } else if (animationValue <= 0.75) {
      // Transition from Yellow to Orange (High)
      final t = (animationValue - 0.5) / 0.25;
      return Color.lerp(Colors.yellow, Colors.deepOrange, t) ?? Colors.yellow;
    } else {
      // Transition from Orange to Red (Critical)
      final t = (animationValue - 0.75) / 0.25;
      return Color.lerp(Colors.deepOrange, AppColors.accent, t) ??
          Colors.deepOrange;
    }
  }

  String _getSeverityLabel() {
    switch (widget.severity.toLowerCase()) {
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
    final label = _getSeverityLabel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity: $label',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            final currentValue = _fillAnimation.value;
            final currentColor = _getSeverityColor(currentValue);

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: currentValue,
                minHeight: 8,
                color: currentColor,
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
              ),
            );
          },
        ),
      ],
    );
  }

  double _severityToValue(String severity) {
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
