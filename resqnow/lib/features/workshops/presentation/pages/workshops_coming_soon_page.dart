import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/role_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/benefit_item.dart';

class WorkshopsComingSoonPage extends StatefulWidget {
  const WorkshopsComingSoonPage({super.key});

  @override
  State<WorkshopsComingSoonPage> createState() =>
      _WorkshopsComingSoonPageState();
}

class _WorkshopsComingSoonPageState extends State<WorkshopsComingSoonPage> {
  bool _isEmailNotified = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('First Aid Workshops'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : AppColors.textPrimary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50,
                    Colors.teal.shade50,
                    Colors.blue.shade50,
                  ],
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHeroSection(context, isDarkMode),
              const SizedBox(height: 32),

              // Coming Soon Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Overview Section
              _buildSectionHeader('What Are First Aid Workshops?', isDarkMode),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'A comprehensive platform for learning and sharing life-saving skills. Whether you\'re a certified first aider looking to volunteer, or someone eager to learn emergency response techniques, our workshops will connect you with expert instructors and passionate learners.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Two Main Roles
              _buildSectionHeader('How Can You Participate?', isDarkMode),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'As a Volunteer',
                      description:
                          'Share your first aid expertise and help others learn life-saving skills',
                      color: const Color(0xFF2E7D32),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoleCard(
                      icon: Icons.school_rounded,
                      title: 'As a Participant',
                      description:
                          'Attend hands-on workshops and gain practical emergency response knowledge',
                      color: const Color(0xFF1976D2),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Volunteer Section
              _buildSectionHeader('Volunteer Registration', isDarkMode),
              const SizedBox(height: 12),
              FeatureCard(
                icon: Icons.check_circle_outline_rounded,
                title: 'Certification Required',
                description:
                    'Must have prior first aid training, CPR certification, or similar emergency response credentials',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              FeatureCard(
                icon: Icons.handshake_rounded,
                title: 'Make a Difference',
                description:
                    'Conduct hands-on workshops and mentor participants in practical emergency techniques',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              FeatureCard(
                icon: Icons.verified_rounded,
                title: 'Volunteer Verification',
                description:
                    'Admin team will verify your credentials and approve your volunteer profile',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 32),

              // Participant Section
              _buildSectionHeader('Participant Registration', isDarkMode),
              const SizedBox(height: 12),
              FeatureCard(
                icon: Icons.school_rounded,
                title: 'Learn Essential Skills',
                description:
                    'Gain hands-on training in CPR, basic life support, wound care, and emergency response',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              FeatureCard(
                icon: Icons.people_rounded,
                title: 'Expert-Led Workshops',
                description:
                    'Learn from certified volunteers and experienced emergency response professionals',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              FeatureCard(
                icon: Icons.location_on_rounded,
                title: 'Flexible Scheduling',
                description:
                    'Choose workshops based on your availability, location, and preferred topics',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 32),

              // Workshop Features
              _buildSectionHeader('What to Expect', isDarkMode),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildExpectationRow(
                      'Varied Topics',
                      'CPR, BLS, first aid, wound care, and more',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    _buildExpectationRow(
                      'Multiple Locations',
                      'Workshops in different areas for easy access',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    _buildExpectationRow(
                      'Different Modes',
                      'Online sessions and in-person hands-on training',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    _buildExpectationRow(
                      'Scheduled Sessions',
                      'Various time slots to fit your schedule',
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Benefits Section
              _buildSectionHeader('Key Benefits', isDarkMode),
              const SizedBox(height: 12),
              BenefitItem(
                icon: Icons.favorite_rounded,
                title: 'Save Lives',
                description:
                    'Acquire and practice skills that can save lives in emergencies',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              BenefitItem(
                icon: Icons.people_outline_rounded,
                title: 'Community Connection',
                description:
                    'Join a network of first aiders and emergency response enthusiasts',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              BenefitItem(
                icon: Icons.emoji_events_rounded,
                title: 'Certifications',
                description:
                    'Receive certificates upon successful workshop completion',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 10),
              BenefitItem(
                icon: Icons.trending_up_rounded,
                title: 'Professional Growth',
                description:
                    'Enhance your resume and professional development with verified credentials',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 32),

              // Admin Section
              _buildSectionHeader('How It\'s Managed', isDarkMode),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800.withValues(alpha: 0.3)
                      : Colors.amber.shade50.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Organized by Admin Team',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our administrative team ensures:\n'
                      '• Volunteer verification and credentialing\n'
                      '• Workshop scheduling and organization\n'
                      '• Quality control and participant safety\n'
                      '• Clear communication of workshop details\n'
                      '• Registration management and confirmations',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Call to Action
              _buildCallToActionSection(context, isDarkMode),
              const SizedBox(height: 20),

              // FAQ-style Section
              _buildSectionHeader('Ready to Get Involved?', isDarkMode),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadyItem(
                      'Volunteers',
                      'When workshops launch, you\'ll be able to register with your credentials for verification.',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.primary.withValues(alpha: 0.1)),
                    const SizedBox(height: 12),
                    _buildReadyItem(
                      'Participants',
                      'Browse upcoming workshops, check dates/locations, and register for sessions that interest you.',
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.primary.withValues(alpha: 0.1)),
                    const SizedBox(height: 12),
                    _buildReadyItem(
                      'Everyone',
                      'Stay updated as we build this feature. We\'ll notify you when workshops are available!',
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Notification Opt-in
              _buildNotificationSection(isDarkMode),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Learn Life-Saving Skills',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Join our community of first aiders and emergency responders to make a difference',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDarkMode ? Colors.white : Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildExpectationRow(
    String title,
    String description,
    bool isDarkMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallToActionSection(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Launch Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re actively developing this feature to ensure it meets the highest standards of quality and safety. The workshops module will launch with:',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '✓ Robust volunteer verification system\n'
            '✓ Comprehensive workshop management tools\n'
            '✓ Secure registration platform\n'
            '✓ Clear communication channels',
            style: TextStyle(
              fontSize: 12,
              height: 1.8,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyItem(String title, String description, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.blue.shade50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Updated',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get notified when workshops are live',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isEmailNotified,
                  onChanged: (value) {
                    setState(() {
                      _isEmailNotified = value;
                    });
                    // TODO: Implement email notification subscription
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              _isEmailNotified
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isEmailNotified
                                  ? 'You\'ll be notified when workshops launch'
                                  : 'Notifications disabled',
                            ),
                          ],
                        ),
                        backgroundColor: _isEmailNotified
                            ? AppColors.primary
                            : Colors.grey.shade600,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: AppColors.primary,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
