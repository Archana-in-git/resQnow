import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/ui_constants.dart';

/// 💬 Floating Action Button for AI Chat (Coming Soon placeholder)
class FloatingAiChatButton extends StatelessWidget {
  const FloatingAiChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIConstants.fabSize,
      height: UIConstants.fabSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () => context.push('/ai-chat-coming-soon'),
        tooltip: 'AI Chat Assistant',
      ),
    );
  }
}
