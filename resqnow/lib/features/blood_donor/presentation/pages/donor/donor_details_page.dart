import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_details_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

class DonorDetailsPage extends StatefulWidget {
  final String donorId;
  final Map<String, dynamic>? extra;

  const DonorDetailsPage({super.key, required this.donorId, this.extra});

  @override
  State<DonorDetailsPage> createState() => _DonorDetailsPageState();
}

class _DonorDetailsPageState extends State<DonorDetailsPage> {
  bool _isApproved = false;
  String? _callRequestId;
  String? _approvedDonorName;
  String? _approvedDonorPhone;

  @override
  void initState() {
    super.initState();

    // Extract extra parameters if provided (from approved notification)
    if (widget.extra != null) {
      _isApproved = widget.extra!['isApproved'] ?? false;
      _callRequestId = widget.extra!['callRequestId'];
      _approvedDonorName = widget.extra!['donorName'];
      _approvedDonorPhone = widget.extra!['donorPhone'];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorDetailsController>().loadDonor(widget.donorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DonorDetailsController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage != null || controller.donor == null) {
          return Scaffold(
            backgroundColor: isDarkMode
                ? Colors.grey.shade900
                : AppColors.background,
            body: Stack(
              children: [
                Center(
                  child: Text(
                    controller.errorMessage ?? "Donor not found.",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimary,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final donor = controller.donor!;

        return Scaffold(
          backgroundColor: isDarkMode
              ? Colors.grey.shade900
              : AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ============ ADVANCED HERO HEADER ============
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
                backgroundColor: isDarkMode
                    ? Colors.grey.shade900
                    : AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildAdvancedHeroSection(donor, isDarkMode),
                ),
              ),

              // ============ MAIN CONTENT ============
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ============ DONATION STATISTICS ============
                      _donationStatsSection(donor, isDarkMode),

                      const SizedBox(height: 24),

                      // ============ CONTACT INFORMATION ============
                      _contactInfoSection(donor, isDarkMode),

                      const SizedBox(height: 24),

                      // ============ MEDICAL CONDITIONS ============
                      if (donor.medicalConditions.isNotEmpty)
                        _medicalConditionsSection(donor, isDarkMode),

                      if (donor.medicalConditions.isNotEmpty)
                        const SizedBox(height: 24),

                      // ============ NOTES ============
                      if (donor.notes != null && donor.notes!.isNotEmpty)
                        _notesSection(donor, isDarkMode),

                      if (donor.notes != null && donor.notes!.isNotEmpty)
                        const SizedBox(height: 32),

                      // ============ QUICK ACTION BUTTONS ============
                      _quickActionButtons(donor, isDarkMode),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========== ADVANCED HERO SECTION ==========
  Widget _buildAdvancedHeroSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.primary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // Availability Status
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                donor.isAvailable
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: donor.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                donor.isAvailable
                                    ? "Available"
                                    : "Not Available",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: donor.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Profile Section
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // Profile Image
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(100),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: donor.profileImageUrl != null
                                  ? NetworkImage(donor.profileImageUrl!)
                                  : null,
                              child: donor.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ),

                          // Blood Group Badge
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                donor.bloodGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name and Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          donor.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${donor.age} years',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                donor.gender,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PREMIUM HERO HEADER ==========
  // ========== QUICK ACTION BUTTONS ==========
  Widget _quickActionButtons(BloodDonor donor, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.phone_rounded,
            label: _isApproved ? 'Call Now' : 'Call',
            color: AppColors.primary,
            isDarkMode: isDarkMode,
            onTap: () {
              if (_isApproved) {
                _launchPhone(donor);
              } else {
                _showCallRequestDialog(donor);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.message_rounded,
            label: 'Message',
            color: Colors.green,
            isDarkMode: isDarkMode,
            onTap: () {
              _navigateToChat(context, donor);
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DONATION STATISTICS SECTION ==========
  Widget _donationStatsSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donation History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  value: donor.totalDonations.toString(),
                  label: 'Total Donations',
                  icon: Icons.bloodtype_rounded,
                  color: Colors.red,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  value: donor.lastDonationDate == null
                      ? 'Never'
                      : donor.lastDonationDate!.toString().substring(0, 10),
                  label: 'Last Donated',
                  icon: Icons.history_rounded,
                  color: Colors.purple,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? Colors.grey.shade400
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== CONTACT INFORMATION SECTION ==========
  Widget _contactInfoSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Address & Contact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show phone number if approved
          if (_isApproved && _approvedDonorPhone != null) ...[
            _contactRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: _approvedDonorPhone!,
              isDarkMode: isDarkMode,
              isCallable: true,
              onTap: () => _launchPhone(donor),
            ),
            const SizedBox(height: 12),
          ],
          if (donor.town != null) ...[
            _contactRow(
              icon: Icons.location_city_rounded,
              label: 'Town',
              value: donor.town!,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
          ],
          if (donor.district != null) ...[
            _contactRow(
              icon: Icons.map_rounded,
              label: 'District',
              value: donor.district!,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
          ],
          if (donor.state != null) ...[
            _contactRow(
              icon: Icons.public_rounded,
              label: 'State',
              value: donor.state!,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
          ],
          if (donor.pincode != null)
            _contactRow(
              icon: Icons.pin_drop_rounded,
              label: 'Pincode',
              value: donor.pincode!,
              isDarkMode: isDarkMode,
            ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    bool isCallable = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isCallable ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    decoration: isCallable ? TextDecoration.underline : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== MEDICAL CONDITIONS SECTION ==========
  Widget _medicalConditionsSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital_rounded,
                color: isDarkMode
                    ? Colors.amber.shade400
                    : Colors.amber.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Medical Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: donor.medicalConditions.map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.amber.shade900.withValues(alpha: 0.25)
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.amber.shade700.withValues(alpha: 0.3)
                        : Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.amber.shade200
                        : Colors.amber.shade900,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ========== NOTES SECTION ==========
  Widget _notesSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.orange.shade900.withValues(alpha: 0.2)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.orange.shade800 : Colors.orange.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: isDarkMode ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? Colors.orange.shade300
                      : Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            donor.notes!,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode
                  ? Colors.orange.shade200
                  : Colors.orange.shade900,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========== CALL DONOR DIRECTLY ==========
  Future<void> _launchPhone(BloodDonor donor) async {
    if (donor.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    try {
      final Uri launchUri = Uri(scheme: 'tel', path: donor.phone);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not launch phone. $e')),
      );
    }
  }

  // ========== CALL REQUEST DIALOG ==========
  void _showCallRequestDialog(BloodDonor donor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Call Request',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Protection',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.amber.shade300
                        : Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To ensure the safety and security of our donors, we do not share their phone numbers directly through the app.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'How it works?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Your request will be submitted to our admin\n• The admin will notify the donor about your request\n• If the donor approves, they can contact you directly',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _requestCallFromDonor(donor);
                Navigator.pop(context);
              },
              child: Text(
                'Request Call',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ========== SUBMIT CALL REQUEST ==========
  Future<void> _requestCallFromDonor(BloodDonor donor) async {
    try {
      final requestId = await context
          .read<DonorDetailsController>()
          .submitCallRequest();

      if (!mounted) return;

      if (requestId != null) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Request Submitted',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Your call request has been submitted successfully. An admin will review it and notify you shortly.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        _handleRequestError(context);
      }
    } catch (e) {
      if (!mounted) return;
      _handleRequestError(context, error: e.toString());
    }
  }

  void _handleRequestError(BuildContext context, {String? error}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Request Failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            error ??
                'Sorry, we could not process your request. Please try again later.',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ========== NAVIGATE TO CHAT ==========
  void _navigateToChat(BuildContext context, BloodDonor donor) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to message donors')),
      );
      return;
    }

    // Get current user info from database or use email as fallback
    // For now, using email name as a placeholder - you should fetch actual user data
    final currentUserName =
        currentUser.displayName ?? currentUser.email?.split('@').first ?? 'You';

    // TODO: Fetch current user's blood group and image from Firestore
    const currentUserBloodGroup = 'O+'; // Placeholder
    final currentUserImageUrl = currentUser.photoURL;

    context.push(
      '/chat/${donor.id}',
      extra: {
        'otherUserId': donor.id,
        'otherUserName': donor.name,
        'otherUserBloodGroup': donor.bloodGroup,
        'otherUserImageUrl': donor.profileImageUrl,
        'currentUserName': currentUserName,
        'currentUserBloodGroup': currentUserBloodGroup,
        'currentUserImageUrl': currentUserImageUrl,
      },
    );
  }

  int max(int a, int b) => a > b ? a : b;
}
