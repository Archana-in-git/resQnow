import 'package:flutter/material.dart';

class AnimatedSOSButton extends StatefulWidget {
  const AnimatedSOSButton({super.key});

  @override
  State<AnimatedSOSButton> createState() => _AnimatedSOSButtonState();
}

class _AnimatedSOSButtonState extends State<AnimatedSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: false);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.shade700,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.6),
              spreadRadius: 12,
              blurRadius: 20,
            ),
          ],
        ),
        child: const Text(
          "SOS",
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
