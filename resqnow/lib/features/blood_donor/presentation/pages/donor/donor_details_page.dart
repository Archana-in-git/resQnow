import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_details_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

class DonorDetailsPage extends StatefulWidget {
  final String donorId;

  const DonorDetailsPage({super.key, required this.donorId});

  @override
  State<DonorDetailsPage> createState() => _DonorDetailsPageState();
}

class _DonorDetailsPageState extends State<DonorDetailsPage> {
  @override
  void initState() {
    super.initState();

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
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ============ PREMIUM HERO HEADER ============
                _premiumHeroHeader(donor, isDarkMode),

                // ============ MAIN CONTENT ============
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ============ DONOR INFO CHIPS ============
                      _donorInfoChips(donor, isDarkMode),

                      const SizedBox(height: 24),

                      // ============ QUICK ACTION BUTTONS ============
                      _quickActionButtons(donor, isDarkMode),

                      const SizedBox(height: 24),

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
                        const SizedBox(height: 24),

                      // ============ PRIMARY CONTACT BUTTONS ============
                      _primaryContactButtons(donor, isDarkMode),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== PREMIUM HERO HEADER ==========
  Widget _premiumHeroHeader(BloodDonor donor, bool isDarkMode) {
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
      child: Column(
        children: [
          // Back Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
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
                        color: donor.isAvailable ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        donor.isAvailable ? "Available" : "Not Available",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: donor.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Profile Section with Overlaid Blood Group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: donor.profileImageUrl != null
                        ? NetworkImage(donor.profileImageUrl!)
                        : null,
                    child: donor.profileImageUrl == null
                        ? Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
                  ),
                ),

                // Blood Group Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
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
                        fontSize: 36,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Name and Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Text(
                  donor.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${donor.age} years • ${donor.gender}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(220),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ========== DONOR INFO CHIPS ==========
  Widget _donorInfoChips(BloodDonor donor, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (donor.pincode != null)
          _infoChip(
            icon: Icons.location_on_rounded,
            label: 'Pincode',
            value: donor.pincode!,
            color: Colors.orange,
            isDarkMode: isDarkMode,
          ),
        _infoChip(
          icon: Icons.phone_rounded,
          label: 'Phone',
          value: donor.phone.substring(max(0, donor.phone.length - 4)),
          color: AppColors.primary,
          isDarkMode: isDarkMode,
        ),
        _infoChip(
          icon: Icons.calendar_today_rounded,
          label: 'Donations',
          value: donor.totalDonations.toString(),
          color: Colors.purple,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey.shade800
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? Colors.grey.shade400
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ========== QUICK ACTION BUTTONS ==========
  Widget _quickActionButtons(BloodDonor donor, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.phone_rounded,
            label: 'Call',
            color: AppColors.primary,
            isDarkMode: isDarkMode,
            onTap: () async {
              final url = Uri.parse("tel:${donor.phone}");
              if (await canLaunchUrl(url)) {
                launchUrl(url);
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
            onTap: () async {
              final url = Uri.parse("sms:${donor.phone}");
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
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
                'Location & Contact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _contactRow(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: donor.phone,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: donor.addressString,
            isDarkMode: isDarkMode,
          ),
          if (donor.town != null) ...[
            const SizedBox(height: 12),
            _contactRow(
              icon: Icons.location_city_rounded,
              label: 'Town',
              value: donor.town!,
              isDarkMode: isDarkMode,
            ),
          ],
          if (donor.district != null) ...[
            const SizedBox(height: 12),
            _contactRow(
              icon: Icons.map_rounded,
              label: 'District',
              value: donor.district!,
              isDarkMode: isDarkMode,
            ),
          ],
          if (donor.state != null) ...[
            const SizedBox(height: 12),
            _contactRow(
              icon: Icons.public_rounded,
              label: 'State',
              value: donor.state!,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
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
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== MEDICAL CONDITIONS SECTION ==========
  Widget _medicalConditionsSection(BloodDonor donor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.green.shade900.withValues(alpha: 0.2)
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.green.shade800 : Colors.green.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: isDarkMode ? 0.1 : 0.05),
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
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Medical Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? Colors.green.shade300
                      : Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...donor.medicalConditions.map((condition) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      condition,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.green.shade200
                            : Colors.green.shade900,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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

  // ========== PRIMARY CONTACT BUTTONS ==========
  Widget _primaryContactButtons(BloodDonor donor, bool isDarkMode) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            onPressed: () async {
              final url = Uri.parse("tel:${donor.phone}");
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
            },
            icon: const Icon(Icons.phone_rounded, size: 20),
            label: const Text(
              "Call Donor Now",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDarkMode ? Colors.grey.shade600 : AppColors.primary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final url = Uri.parse("sms:${donor.phone}");
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
            },
            icon: Icon(
              Icons.sms_rounded,
              size: 20,
              color: isDarkMode ? Colors.grey.shade400 : AppColors.primary,
            ),
            label: Text(
              "Send Message",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey.shade400 : AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  int max(int a, int b) => a > b ? a : b;
}
