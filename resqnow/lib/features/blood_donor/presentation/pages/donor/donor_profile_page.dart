// lib/features/blood_donor/presentation/pages/donor/donor_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_profile_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorProfileController>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProfileController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.donor == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                controller.errorMessage ?? "Profile unavailable",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
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
                const SizedBox(height: 12),
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
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
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),

                // Edit Button
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showEditBottomSheet(context, controller, donor),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
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
                          color: AppColors.primary.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
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
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  donor.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Age & Gender
                Text(
                  '${donor.age} • ${donor.gender}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Blood Group Badge - Circular
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      donor.bloodGroup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Availability Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Available for Donation",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                ),

                const SizedBox(height: 20),

                // ============ DETAILS SECTION ============
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Personal Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _detailRow(
                        Icons.calendar_today_rounded,
                        "Age",
                        donor.age.toString(),
                      ),
                      _detailRow(Icons.person_rounded, "Gender", donor.gender),
                      _detailRow(Icons.phone_rounded, "Phone", donor.phone),
                      _detailRow(
                        Icons.location_on_rounded,
                        "Address",
                        donor.addressString,
                      ),
                      _detailRow(
                        Icons.history_rounded,
                        "Last Donation",
                        donor.lastDonationDate == null
                            ? "Not yet donated"
                            : donor.lastDonationDate!.toString().substring(
                                0,
                                10,
                              ),
                      ),
                      _detailRow(
                        Icons.bloodtype_rounded,
                        "Total Donations",
                        donor.totalDonations.toString(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ============ MEDICAL CONDITIONS ============
                if (donor.medicalConditions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
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
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  condition,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ============ NOTES ============
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_rounded,
                              color: Colors.orange.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Notes",
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
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
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

  void _showEditBottomSheet(
    BuildContext context,
    DonorProfileController controller,
    BloodDonor donor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileForm(donor: donor, controller: controller),
    );
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

    setState(() => isLoading = true);

    final success = await widget.controller.updateProfile(
      name: nameCtrl.text.trim(),
      age: int.tryParse(ageCtrl.text.trim()) ?? widget.donor.age,
      gender: selectedGender,
      bloodGroup: selectedBloodGroup,
      phone: phoneCtrl.text.trim(),
      permanentAddress: {
        ...widget.donor.permanentAddress,
        "pincode": pincodeCtrl.text.trim(),
      },
      addressString: _buildAddressString(),
      medicalConditions: selectedConditions,
      notes: notesCtrl.text.trim(),
    );

    setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
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
      widget.donor.town,
      widget.donor.district,
      widget.donor.state,
      pincode,
    ].where((x) => x != null && x.isNotEmpty).toList();
    return parts.join(", ");
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
                      color: AppColors.primary.withOpacity(0.1),
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
              readOnly: true,
              icon: Icons.phone_outlined,
            ),
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
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                              )
                            : null,
                        color: selected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary.withOpacity(0.6)
                              : Colors.grey.shade300,
                          width: selected ? 1.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
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
                          AppColors.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLoading ? null : _saveChanges,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: isLoading
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
            color: AppColors.primary.withOpacity(0.1),
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
}
