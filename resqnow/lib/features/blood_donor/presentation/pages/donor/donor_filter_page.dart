import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_filter_controller.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorFilterPage extends StatefulWidget {
  const DonorFilterPage({super.key});

  @override
  State<DonorFilterPage> createState() => _DonorFilterPageState();
}

class _DonorFilterPageState extends State<DonorFilterPage> {
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

  final List<String> genders = ["Male", "Female", "Other"];

  RangeValues ageRange = const RangeValues(18, 60);

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    return Consumer<DonorFilterController>(
      builder: (context, controller, _) {
        // Pre-fill district only ONCE
        controller.selectedDistrict ??= location.detectedDistrict;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ============ HEADER WITH BACK BUTTON ============
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

                const SizedBox(height: 16),

                // ============ TITLE SECTION ============
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter Donors",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.resetFilters();
                        setState(() {
                          ageRange = const RangeValues(18, 60);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ============ BLOOD GROUP SECTION ============
                _buildSectionCard(
                  icon: Icons.bloodtype_rounded,
                  iconColor: Colors.red,
                  title: "Blood Group",
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Blood Group",
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.bloodtype_rounded),
                    ),
                    value: controller.selectedBloodGroup,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Any")),
                      ...bloodGroups.map(
                        (b) => DropdownMenuItem(value: b, child: Text(b)),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => controller.selectedBloodGroup = val);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ============ GENDER SECTION ============
                _buildSectionCard(
                  icon: Icons.person_rounded,
                  iconColor: AppColors.primary,
                  title: "Gender",
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Gender",
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    value: controller.selectedGender,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Any")),
                      ...genders.map(
                        (g) => DropdownMenuItem(value: g, child: Text(g)),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => controller.selectedGender = val);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ============ AGE RANGE SECTION ============
                _buildSectionCard(
                  icon: Icons.cake_rounded,
                  iconColor: Colors.orange,
                  title: "Age Range",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${ageRange.start.toInt()} years",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            "${ageRange.end.toInt()} years",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RangeSlider(
                        values: ageRange,
                        min: 18,
                        max: 100,
                        divisions: 82,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.1),
                        labels: RangeLabels(
                          "${ageRange.start.toInt()}",
                          "${ageRange.end.toInt()}",
                        ),
                        onChanged: (values) {
                          setState(() {
                            ageRange = values;
                            controller.minAge = values.start.toInt();
                            controller.maxAge = values.end.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ============ AVAILABILITY SECTION ============
                _buildSectionCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  title: "Availability",
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available for Donation",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Switch(
                          value: controller.isAvailable ?? false,
                          onChanged: (val) {
                            setState(() {
                              controller.isAvailable = val;
                            });
                          },
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============ LOCATION SECTION ============
                _buildSectionCard(
                  icon: Icons.location_on_rounded,
                  iconColor: Colors.red,
                  title: "Location",
                  child: Column(
                    children: [
                      // District
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "District",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.map_rounded),
                          suffixIcon: const Icon(Icons.location_city_rounded),
                        ),
                        controller: TextEditingController(
                          text: controller.selectedDistrict ?? "",
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Town
                      if (location.availableTowns.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value:
                              controller.selectedTown ?? location.selectedTown,
                          decoration: InputDecoration(
                            labelText: "Town / Locality",
                            labelStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.location_on_rounded),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Any"),
                            ),
                            ...location.availableTowns.map(
                              (town) => DropdownMenuItem(
                                value: town,
                                child: Text(town),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              controller.selectedTown = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ============ APPLY FILTERS BUTTON ============
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
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            await controller.applyFilters();
                            if (!mounted) return;
                            navigator.pop(controller.filteredDonors);
                          },
                    icon: controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.filter_alt_rounded, size: 20),
                    label: Text(
                      controller.isLoading ? "Applying..." : "Apply Filters",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Error Message
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_rounded,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Content
          child,
        ],
      ),
    );
  }
}
