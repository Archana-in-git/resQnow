import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/ui_constants.dart';
import 'package:resqnow/features/authentication/presentation/controllers/auth_controller.dart';

class ResQNowNavBar extends StatefulWidget {
  const ResQNowNavBar({super.key});

  @override
  State<ResQNowNavBar> createState() => _ResQNowNavBarState();
}

class _ResQNowNavBarState extends State<ResQNowNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Drawer(
          width: MediaQuery.of(context).size.width * 0.75,
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Enhanced Header Section
                _buildHeaderSection(context),

                const SizedBox(height: 8),

                // 🔹 Drawer Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.home_rounded,
                          label: "Home",
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/home');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.local_hospital_rounded,
                          label: "Nearby Hospitals",
                          color: const Color(0xFF6A4C93),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/blood-banks');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.favorite_rounded,
                          label: "Saved Conditions",
                          color: const Color(0xFFD32F2F),
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildMenuItem(
                          icon: Icons.psychology_rounded,
                          label: "AI Chat Assistant",
                          color: const Color(0xFF1976D2),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/ai-chat-coming-soon');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.bloodtype_rounded,
                          label: "Blood Donors",
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/donors');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.warning_rounded,
                          label: "Emergency",
                          color: const Color(0xFFFFA000),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/emergency');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.settings_rounded,
                          label: "Settings",
                          color: const Color(0xFF455A64),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Footer Section with Logout
                _buildFooterSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Welcome to",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const Text(
            "ResQNow",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: const Text(
              "🚑 Emergency Medical Assistance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.1),
          splashColor: color.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.grey.withOpacity(0.3),
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthController>().signOut();
              },
              borderRadius: BorderRadius.circular(12),
              hoverColor: const Color(0xFFD32F2F).withOpacity(0.1),
              splashColor: const Color(0xFFD32F2F).withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD32F2F).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFD32F2F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Logout",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFFD32F2F).withOpacity(0.4),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
