// lib/features/blood_donor/presentation/pages/donor/donor_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_profile_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crop_your_image/crop_your_image.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  bool _notDonorDialogShown = false;
  bool _justCompletedRegistration = false;
  bool _dependenciesChecked = false;
  bool _firstLoadChecked = false;
  bool _loadInitiated = false; // Track if we've initiated loadProfile
  bool _isDeleting = false; // Prevents page rebuilding during deletion

  @override
  void initState() {
    super.initState();
    // Load profile initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitiated = true; // Mark that load has been initiated
      context.read<DonorProfileController>().loadProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we just completed registration (only once)
    if (!_dependenciesChecked) {
      _dependenciesChecked = true;
      try {
        final routerState = GoRouterState.of(context);
        if (routerState.extra is Map) {
          final extra = routerState.extra as Map;
          _justCompletedRegistration = extra['justRegistered'] ?? false;
        }
      } catch (e) {
        debugPrint('Error accessing GoRouterState: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProfileController>(
      builder: (context, controller, _) {
        // CRITICAL: If profile is being deleted, prevent any rebuilds
        // This stops the page from showing spinner when donor becomes null
        if (_isDeleting) {
          return const Scaffold(body: SizedBox.shrink());
        }

        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check on first load completion if donor is null
        // CRITICAL: Only check AFTER we've initiated load AND loading is complete
        if (_loadInitiated && !_firstLoadChecked && !controller.isLoading) {
          _firstLoadChecked = true;
          if (controller.donor == null &&
              !_notDonorDialogShown &&
              !_justCompletedRegistration &&
              mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _notDonorDialogShown = true;
                _showNotDonorDialog(context);
              }
            });
          }
        }

        if (controller.donor == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final donor = controller.donor!;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ============ ADVANCED HERO HEADER ============
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildAdvancedHeroSection(context, donor),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showEditBottomSheet(context, controller, donor),
                    ),
                  ),
                ],
              ),

              // ============ MAIN CONTENT ============
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ============ KEY STATS SECTION ============
                      _buildStatsSection(donor),

                      const SizedBox(height: 24),

                      // ============ STATUS & AVAILABILITY ============
                      _buildStatusSection(context, controller, donor),

                      const SizedBox(height: 24),

                      // ============ DETAILED INFORMATION CARDS ============
                      _buildDetailedInfoCards(donor),

                      const SizedBox(height: 24),

                      // ============ MEDICAL CONDITIONS ============
                      if (donor.medicalConditions.isNotEmpty)
                        _buildMedicalConditionsCard(donor),

                      if (donor.medicalConditions.isNotEmpty)
                        const SizedBox(height: 24),

                      // ============ NOTES SECTION ============
                      if (donor.notes != null && donor.notes!.isNotEmpty)
                        _buildNotesCard(donor),

                      if (donor.notes != null && donor.notes!.isNotEmpty)
                        const SizedBox(height: 24),

                      // ============ DELETE PROFILE SECTION ============
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Delete Profile',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
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

  // ============ ADVANCED HERO SECTION ============
  Widget _buildAdvancedHeroSection(BuildContext context, BloodDonor donor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Picture with Badge
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            backgroundImage: donor.profileImageUrl != null
                                ? NetworkImage(donor.profileImageUrl!)
                                : null,
                            child: donor.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: donor.isAvailable
                                  ? AppColors.success
                                  : Colors.grey,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Icon(
                              donor.isAvailable
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      donor.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        donor.isAvailable
                            ? '✓ Available for Donation'
                            : '✗ Not Available',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ STATS SECTION ============
  Widget _buildStatsSection(BloodDonor donor) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.bloodtype_rounded,
          label: 'Blood Group',
          value: donor.bloodGroup,
          color: Colors.red,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.favorite_rounded,
          label: 'Total Donations',
          value: donor.totalDonations.toString(),
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.calendar_today_rounded,
          label: 'Last Donation',
          value: donor.lastDonationDate == null
              ? 'Never'
              : donor.lastDonationDate!.toString().substring(0, 10),
          color: Colors.orange,
          isSmall: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 13 : 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============ STATUS SECTION ============
  Widget _buildStatusSection(
    BuildContext context,
    DonorProfileController controller,
    BloodDonor donor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Availability Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                donor.isAvailable
                    ? "You are available for donations"
                    : "You are not currently available",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: donor.isAvailable,
            onChanged: (v) {
              controller.updateAvailability(v);
            },
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  // ============ BLOOD GROUP HIGHLIGHT ============
  // (Unused - removed to clean up code)

  // ============ DETAILED INFO (MINIMAL LIST STYLE WITH CARD) ============
  Widget _buildDetailedInfoCards(BloodDonor donor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          _buildAboutListItem(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: donor.phone,
            isDarkMode: isDarkMode,
            color: Colors.blue,
          ),
          _buildAboutDivider(isDarkMode),
          _buildAboutListItem(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: donor.addressString,
            isDarkMode: isDarkMode,
            color: Colors.green,
            maxLines: 2,
          ),
          _buildAboutDivider(isDarkMode),
          Row(
            children: [
              Expanded(
                child: _buildAboutListItem(
                  icon: Icons.cake_rounded,
                  label: 'Age',
                  value: donor.age.toString(),
                  isDarkMode: isDarkMode,
                  color: Colors.orange,
                  showBorder: false,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildAboutListItem(
                  icon: Icons.person_rounded,
                  label: 'Gender',
                  value: donor.gender,
                  isDarkMode: isDarkMode,
                  color: Colors.purple,
                  showBorder: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutListItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    required Color color,
    int maxLines = 1,
    bool showBorder = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        height: 1,
        thickness: 1,
      ),
    );
  }

  // ============ MEDICAL CONDITIONS CARD ============
  Widget _buildMedicalConditionsCard(BloodDonor donor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                        ? Colors.amber.shade800
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

  // ============ NOTES CARD ============
  Widget _buildNotesCard(BloodDonor donor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.note_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Additional Notes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            donor.notes ?? "",
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade900,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    DonorProfileController controller,
    BloodDonor donor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileForm(
        donor: controller.donor ?? donor,
        controller: controller,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Profile?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: const Text(
          'This will permanently delete your donor profile. You can register as a donor again anytime.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isDeleting = true);
              final success = await context
                  .read<DonorProfileController>()
                  .deleteProfile();
              if (success && mounted) {
                context.go('/home');
              } else if (mounted) {
                setState(() => _isDeleting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<DonorProfileController>().errorMessage ??
                          'Failed to delete profile',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showNotDonorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Not a Donor',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ],
        ),
        content: const Text(
          'You are not registered as a blood donor. Register now to create your donor profile and help save lives!',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'home');
            },
            child: const Text('Go Home'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, 'register');
            },
            child: const Text('Register as Donor'),
          ),
        ],
      ),
    ).then((result) {
      if (mounted) {
        if (result == 'home' || result == null) {
          // Go to home if "Go Home" clicked or dialog dismissed by back button
          context.go('/home');
        } else if (result == 'register') {
          // Go to registration page (replaces profile in stack)
          context.go('/donor/register');
        }
      }
    });
  }
}

/// Edit Profile Form Widget
class _EditProfileForm extends StatefulWidget {
  final BloodDonor donor;
  final DonorProfileController controller;

  const _EditProfileForm({required this.donor, required this.controller});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late TextEditingController nameCtrl;
  late TextEditingController ageCtrl;
  late TextEditingController genderCtrl;
  late TextEditingController bloodGroupCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController pincodeCtrl;
  late TextEditingController notesCtrl;

  late String selectedGender;
  late String selectedBloodGroup;
  late List<String> selectedConditions;

  // Address data
  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;
  List<String> statesList = [];
  List<String> districtsList = [];
  List<String> citiesList = [];
  Map<String, dynamic>? allCitiesData;
  bool _addressDataLoaded = false;

  File? _pickedImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  final List<String> genderList = ["Male", "Female", "Other"];
  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  final List<String> conditions = [
    "Diabetes",
    "Blood Pressure",
    "Thyroid",
    "Asthma",
    "None",
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.donor.name);
    ageCtrl = TextEditingController(text: widget.donor.age.toString());
    genderCtrl = TextEditingController(text: widget.donor.gender);
    bloodGroupCtrl = TextEditingController(text: widget.donor.bloodGroup);
    phoneCtrl = TextEditingController(text: widget.donor.phone);
    pincodeCtrl = TextEditingController(text: widget.donor.pincode ?? "");
    notesCtrl = TextEditingController(text: widget.donor.notes ?? "");

    selectedGender = widget.donor.gender;
    selectedBloodGroup = widget.donor.bloodGroup;
    selectedConditions = List.from(widget.donor.medicalConditions);
    _uploadedImageUrl = widget.donor.profileImageUrl;

    // Initialize address from donor data - use the separate fields
    selectedState = widget.donor.state;
    selectedDistrict = widget.donor.district;
    selectedCity = widget.donor.town;

    _loadAddressData();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
    bloodGroupCtrl.dispose();
    phoneCtrl.dispose();
    pincodeCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  void _onConditionTap(String c) {
    setState(() {
      if (c == "None") {
        if (selectedConditions.contains("None")) {
          selectedConditions.remove("None");
        } else {
          selectedConditions = ["None"];
        }
      } else {
        if (selectedConditions.contains(c)) {
          selectedConditions.remove(c);
        } else {
          if (selectedConditions.contains("None")) {
            selectedConditions.remove("None");
          }
          selectedConditions.add(c);
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    if (selectedState == null ||
        selectedDistrict == null ||
        selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select State, District, and Town/City"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    var profileImageUrlToSave = _uploadedImageUrl;

    if (_pickedImageFile != null && _uploadedImageUrl == null) {
      setState(() => _isUploadingImage = true);
      try {
        final uploadedUrl = await _uploadImageToFirebase(_pickedImageFile!);
        profileImageUrlToSave = uploadedUrl;
        _uploadedImageUrl = uploadedUrl;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile image upload failed. Try again."),
            ),
          );
        }
        setState(() {
          isLoading = false;
          _isUploadingImage = false;
        });
        return;
      }
      setState(() => _isUploadingImage = false);
    }

    final success = await widget.controller.updateProfile(
      name: nameCtrl.text.trim(),
      age: int.tryParse(ageCtrl.text.trim()) ?? widget.donor.age,
      gender: selectedGender,
      bloodGroup: selectedBloodGroup,
      phone: phoneCtrl.text.trim(),
      state: selectedState,
      district: selectedDistrict,
      town: selectedCity,
      pincode: pincodeCtrl.text.trim(),
      country: widget.donor.country,
      addressString: _buildAddressString(),
      medicalConditions: selectedConditions,
      notes: notesCtrl.text.trim(),
      profileImageUrl: profileImageUrlToSave,
    );

    setState(() => isLoading = false);

    if (success && mounted) {
      // Reload profile to ensure latest data is available
      await widget.controller.loadProfile();

      if (mounted) {
        Navigator.pop(context);
        _showBeautifulSuccessAlert();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? "Failed to update profile",
          ),
        ),
      );
    }
  }

  String _buildAddressString() {
    final pincode = pincodeCtrl.text.trim();
    final parts = [
      selectedCity,
      selectedDistrict,
      selectedState,
      pincode,
    ].where((x) => x != null && x.isNotEmpty).whereType<String>().toList();
    return parts.join(", ");
  }

  Future<void> _loadAddressData() async {
    try {
      // Load states
      final statesStr = await rootBundle.loadString(
        'assets/data/states_india.json',
      );
      final statesJson = json.decode(statesStr) as Map<String, dynamic>?;
      final rawStates = (statesJson ?? {})['states'] as List<dynamic>?;

      if (rawStates != null && rawStates.isNotEmpty) {
        statesList = rawStates.map((e) => e['name'].toString()).toList();
      }

      // Load districts
      final districtsStr = await rootBundle.loadString(
        'assets/data/districts_kerala.json',
      );
      final districtsJson = json.decode(districtsStr) as Map<String, dynamic>?;
      final rawDistricts = (districtsJson ?? {})['districts'] as List<dynamic>?;
      if (rawDistricts != null && rawDistricts.isNotEmpty) {
        districtsList = rawDistricts.map((e) => e.toString()).toList();
      }

      // Load cities
      final citiesStr = await rootBundle.loadString(
        'assets/data/cities_kerala.json',
      );
      final citiesJson = json.decode(citiesStr) as Map<String, dynamic>?;

      if (citiesJson != null && citiesJson.containsKey('Kerala')) {
        allCitiesData = citiesJson['Kerala'] as Map<String, dynamic>;

        // If district is selected, load its cities
        if (selectedDistrict != null &&
            allCitiesData!.containsKey(selectedDistrict)) {
          citiesList = List<String>.from(
            allCitiesData![selectedDistrict] ?? <String>[],
          );
          citiesList.sort();
        }
      }

      setState(() {
        _addressDataLoaded = true;
      });
    } catch (e) {
      debugPrint('Failed to load address data: $e');
      setState(() {
        _addressDataLoaded = true;
      });
    }
  }

  void _updateCitiesList() {
    if (selectedDistrict != null &&
        allCitiesData != null &&
        allCitiesData!.containsKey(selectedDistrict)) {
      setState(() {
        citiesList = List<String>.from(
          allCitiesData![selectedDistrict] ?? <String>[],
        );
        citiesList.sort();
        selectedCity = null;
      });
    } else {
      setState(() {
        citiesList = [];
        selectedCity = null;
      });
    }
  }

  Future<void> _onStateChanged(String newState) async {
    setState(() {
      selectedState = newState;
      selectedDistrict = null;
      selectedCity = null;
      citiesList = [];
    });

    // Reload districts and cities for the selected state
    try {
      // Load districts
      final districtsStr = await rootBundle.loadString(
        'assets/data/districts_kerala.json',
      );
      final districtsJson = json.decode(districtsStr) as Map<String, dynamic>?;
      final rawDistricts = (districtsJson ?? {})['districts'] as List<dynamic>?;

      if (rawDistricts != null && rawDistricts.isNotEmpty) {
        setState(() {
          districtsList = rawDistricts.map((e) => e.toString()).toList();
        });
      }

      // Load cities
      final citiesStr = await rootBundle.loadString(
        'assets/data/cities_kerala.json',
      );
      final citiesJson = json.decode(citiesStr) as Map<String, dynamic>?;

      if (citiesJson != null && citiesJson.containsKey('Kerala')) {
        setState(() {
          allCitiesData = citiesJson['Kerala'] as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Failed to reload address data for state: $e');
    }
  }

  Future<void> _showImageSourceSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_pickedImageFile != null || _uploadedImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pickedImageFile = null;
                      _uploadedImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) return;

      final imageBytes = await picked.readAsBytes();
      final cropController = CropController();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final isDarkDialog = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDarkDialog
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 420,
              child: Column(
                children: [
                  Expanded(
                    child: Crop(
                      controller: cropController,
                      image: imageBytes,
                      aspectRatio: 1,
                      withCircleUi: false,
                      maskColor: Colors.black38,
                      baseColor: Colors.black,
                      onCropped: (croppedBytes) async {
                        final tempDir = await getTemporaryDirectory();
                        final file = File(
                          "${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg",
                        );
                        await file.writeAsBytes(croppedBytes);

                        setState(() {
                          _pickedImageFile = file;
                          _uploadedImageUrl = null;
                        });

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () {
                        cropController.crop();
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Image pick/crop failed: $e");
    }
  }

  Future<String> _uploadImageToFirebase(File file) async {
    final storage = FirebaseStorage.instance;
    final fileName =
        "${widget.donor.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = storage.ref().child('donor_profile_pics').child(fileName);

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Widget _buildProfilePhotoEditor() {
    ImageProvider? imageProvider;

    if (_pickedImageFile != null) {
      imageProvider = FileImage(_pickedImageFile!);
    } else if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_uploadedImageUrl!);
    }

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Icon(
                          Icons.person_outline,
                          size: 50,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      imageProvider == null ? Icons.add : Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            "Profile Photo",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
        if (_isUploadingImage) ...[
          const SizedBox(height: 10),
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Uploading...",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  void _showBeautifulSuccessAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto-close after 2.5 seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Profile Updated!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Your changes have been saved',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noneSelected = selectedConditions.contains("None");

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============ HEADER ============
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Update your information",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildProfilePhotoEditor(),

            const SizedBox(height: 24),

            // ============ PERSONAL INFORMATION SECTION ============
            _buildSectionHeader("Personal Information", Icons.person_rounded),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Name",
                    nameCtrl,
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    "Age",
                    ageCtrl,
                    keyboardType: TextInputType.number,
                    icon: Icons.cake_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _buildGenderDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildBloodGroupDropdown()),
              ],
            ),

            const SizedBox(height: 24),

            // ============ CONTACT & ADDRESS SECTION ============
            _buildSectionHeader("Contact & Address", Icons.location_on_rounded),
            const SizedBox(height: 12),

            _buildTextField(
              "Phone",
              phoneCtrl,
              readOnly: false,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 14),

            // State Dropdown
            _buildStateDropdown(),
            const SizedBox(height: 14),

            // District Dropdown
            _buildDistrictDropdown(),
            const SizedBox(height: 14),

            // City Dropdown
            _buildCityDropdown(),
            const SizedBox(height: 14),

            _buildTextField(
              "PIN Code",
              pincodeCtrl,
              keyboardType: TextInputType.number,
              icon: Icons.pin_drop_outlined,
            ),

            const SizedBox(height: 24),

            // ============ MEDICAL INFORMATION SECTION ============
            _buildSectionHeader(
              "Medical Information",
              Icons.local_hospital_rounded,
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: Wrap(
                spacing: 9,
                runSpacing: 9,
                children: conditions.map((c) {
                  final selected = selectedConditions.contains(c);
                  final disabled = noneSelected && c != "None";

                  return GestureDetector(
                    onTap: disabled ? null : () => _onConditionTap(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.08),
                                ],
                              )
                            : null,
                        color: selected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : Colors.grey.shade300,
                          width: selected ? 1.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade700,
                          fontSize: 13,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // Notes
            _buildTextField(
              "Notes",
              notesCtrl,
              maxLines: 3,
              enabled: !noneSelected,
              icon: Icons.note_outlined,
            ),

            const SizedBox(height: 28),

            // ============ ACTION BUTTONS ============
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (isLoading || _isUploadingImage)
                            ? null
                            : _saveChanges,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: (isLoading || _isUploadingImage)
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    bool enabled = true,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 10),
                    child: Icon(
                      icon,
                      size: 20,
                      color: enabled ? AppColors.primary : Colors.grey.shade400,
                    ),
                  )
                : null,
            prefixIconConstraints: icon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            value: selectedGender,
            items: genderList.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Row(
                  children: [
                    Icon(
                      gender == "Male"
                          ? Icons.male_rounded
                          : gender == "Female"
                          ? Icons.female_rounded
                          : Icons.person_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      gender,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedGender = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Blood Group",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            value: selectedBloodGroup,
            items: bloodGroups.map((bg) {
              return DropdownMenuItem(
                value: bg,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade600,
                      ),
                      child: Center(
                        child: Text(
                          bg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      bg,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedBloodGroup = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "State",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            value: selectedState,
            hint: const Text(
              "Select State",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            items: statesList.map<DropdownMenuItem<String>>((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(
                  state,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _onStateChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    final districts = _addressDataLoaded ? districtsList : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "District",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            value: selectedDistrict,
            hint: const Text(
              "Select District",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            items: districts.map((district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(
                  district,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedDistrict = value;
                  selectedCity = null;
                });
                _updateCitiesList();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    final cities = _addressDataLoaded ? citiesList : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Town/City",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            value: selectedCity,
            hint: const Text(
              "Select Town/City",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(
                  city,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCity = value);
              }
            },
          ),
        ),
      ],
    );
  }
}
