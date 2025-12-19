import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/core/constants/ui_constants.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_list_controller.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/features/blood_donor/presentation/widgets/donor_card.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorListPage extends StatefulWidget {
  const DonorListPage({super.key});

  @override
  State<DonorListPage> createState() => _DonorListPageState();
}

class _DonorListPageState extends State<DonorListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorListController>().loadDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();

    return Consumer<DonorListController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Nearby Donors"),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => context.push('/donor/filter'),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 LOCATION CARD
              Padding(
                padding: const EdgeInsets.all(UIConstants.screenPadding),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.95),
                        AppColors.primary.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT LOCATION',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location.locationText,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // District & Town Display
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DISTRICT',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller.detectedDistrict ??
                                            'Detecting...',
                                        style: AppTextStyles.sectionTitle
                                            .copyWith(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 🔄 EDIT DISTRICT BUTTON
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showDistrictSelector(
                                        context,
                                        controller,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 🏙️ TOWN SELECTOR (inside card)
                            if (location.availableTowns.length > 1) ...[
                              const SizedBox(height: 12),
                              Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELECT TOWN',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: controller.selectedTown,
                                        decoration: InputDecoration(
                                          hintText: 'Choose a town',
                                          hintStyle: AppTextStyles.bodyText
                                              .copyWith(
                                                color: Colors.white54,
                                                fontSize: 14,
                                              ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                        ),
                                        items: location.availableTowns
                                            .map(
                                              (town) => DropdownMenuItem(
                                                value: town,
                                                child: Text(
                                                  town,
                                                  style: AppTextStyles.bodyText
                                                      .copyWith(
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setManualTown(value);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.expand_more_rounded,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        isExpanded: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (controller.selectedTown != null) ...[
                              const SizedBox(height: 12),
                              Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELECTED TOWN',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.selectedTown!,
                                    style: AppTextStyles.bodyText.copyWith(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 📋 DONOR LIST AREA
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.refresh,
                  child: _buildDonorList(controller),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonorList(DonorListController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          controller.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (controller.donors.isEmpty) {
      return const Center(
        child: Text(
          "No donors found in this area",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.donors.length,
      itemBuilder: (context, index) {
        final donor = controller.donors[index];
        return DonorCard(
          donor: donor,
          onTap: () => context.push('/donor/details/${donor.id}'),
        );
      },
    );
  }

  // 🎯 DISTRICT SELECTOR BOTTOM SHEET
  void _showDistrictSelector(
    BuildContext context,
    DonorListController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select District',
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a district to see donors nearby',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Districts List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Palakkad - only district for now
                    _buildDistrictOption(
                      context,
                      controller,
                      'Palakkad',
                      Icons.map_rounded,
                      isSelected: controller.detectedDistrict == 'Palakkad',
                    ),
                    // Future districts can be added here
                    // _buildDistrictOption(context, controller, 'Ernakulam', Icons.map_rounded),
                    // _buildDistrictOption(context, controller, 'Kottayam', Icons.map_rounded),
                  ],
                ),
              ),
              // Close padding
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // District option widget
  Widget _buildDistrictOption(
    BuildContext context,
    DonorListController controller,
    String districtName,
    IconData icon, {
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            controller.setManualDistrict(districtName);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        districtName,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      if (isSelected)
                        Text(
                          'Currently selected',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
