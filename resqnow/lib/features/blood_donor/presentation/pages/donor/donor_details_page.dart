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
    return Consumer<DonorDetailsController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage != null || controller.donor == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
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
                      color: AppColors.white,
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
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
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
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ============ PROFILE HEADER CARD ============
                _profileHeader(donor),

                const SizedBox(height: 20),

                // ============ QUICK INFO STATS ============
                _quickStatsCard(donor),

                const SizedBox(height: 20),

                // ============ DETAILED INFO ============
                _infoCard(donor),

                const SizedBox(height: 20),

                // ============ MEDICAL CONDITIONS ============
                if (donor.medicalConditions.isNotEmpty) _conditionsCard(donor),

                const SizedBox(height: 20),

                // ============ NOTES ============
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  _notesCard(donor),

                const SizedBox(height: 20),

                // ============ CALL & CONTACT BUTTONS ============
                _contactButtons(donor),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== PROFILE HEADER WITH CIRCULAR BLOOD GROUP ==========
  Widget _profileHeader(BloodDonor donor) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Back Button
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Profile Picture with Status Badge
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: donor.profileImageUrl != null
                    ? NetworkImage(donor.profileImageUrl!)
                    : null,
                child: donor.profileImageUrl == null
                    ? Icon(Icons.person, size: 54, color: AppColors.primary)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: donor.isAvailable
                      ? AppColors.success
                      : AppColors.textSecondary,
                  border: Border.all(color: AppColors.white, width: 4),
                ),
                width: 28,
                height: 28,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Name
        Text(
          donor.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        // Age & Gender & Pincode
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${donor.age} • ${donor.gender}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (donor.pincode != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  donor.pincode!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Blood Group - Circular Large Badge
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.25),
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
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Availability Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: donor.isAvailable
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: donor.isAvailable
                  ? AppColors.success.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                donor.isAvailable ? Icons.check_circle : Icons.cancel,
                color: donor.isAvailable ? AppColors.success : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                donor.isAvailable ? "Available for Donation" : "Not Available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: donor.isAvailable ? AppColors.success : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== QUICK STATS CARD ==========
  Widget _quickStatsCard(BloodDonor donor) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            icon: Icons.bloodtype_rounded,
            label: "Total",
            value: donor.totalDonations.toString(),
            bgColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            icon: Icons.history_rounded,
            label: "Last Donated",
            value: donor.lastDonationDate == null
                ? "Never"
                : donor.lastDonationDate!.toString().substring(0, 10),
            bgColor: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: bgColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: bgColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== DETAILED INFO CARD ==========
  Widget _infoCard(BloodDonor donor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Text(
                "Contact Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.phone_rounded, "Phone", donor.phone),
          _infoRow(Icons.location_on_rounded, "Address", donor.addressString),
          if (donor.town != null)
            _infoRow(Icons.location_city_rounded, "Town", donor.town!),
          if (donor.district != null)
            _infoRow(Icons.map_rounded, "District", donor.district!),
          if (donor.state != null)
            _infoRow(Icons.public_rounded, "State", donor.state!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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

  // ========== MEDICAL CONDITIONS CARD ==========
  Widget _conditionsCard(BloodDonor donor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital_rounded,
                color: Colors.green.shade700,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Medical Conditions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...donor.medicalConditions.map((condition) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
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
                        fontSize: 14,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ========== NOTES CARD ==========
  Widget _notesCard(BloodDonor donor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_rounded, color: Colors.orange.shade700, size: 22),
              const SizedBox(width: 10),
              Text(
                "Additional Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            donor.notes!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade900,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========== CONTACT BUTTONS ==========
  Widget _contactButtons(BloodDonor donor) {
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
              elevation: 2,
            ),
            onPressed: () async {
              final url = Uri.parse("tel:${donor.phone}");
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              }
            },
            icon: const Icon(Icons.phone_rounded, size: 20),
            label: const Text(
              "Call Donor",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 2),
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
            icon: const Icon(Icons.sms_rounded, size: 20),
            label: const Text(
              "Send Message",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
