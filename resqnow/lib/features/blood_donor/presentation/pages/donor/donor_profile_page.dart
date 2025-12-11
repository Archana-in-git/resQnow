// lib/features/blood_donor/presentation/pages/donor/donor_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_profile_controller.dart';

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
            appBar: AppBar(title: const Text("My Donor Profile")),
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
          appBar: AppBar(title: const Text("My Donor Profile"), elevation: 0),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: donor.profileImageUrl != null
                            ? NetworkImage(donor.profileImageUrl!)
                            : null,
                        child: donor.profileImageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        donor.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Blood Group: ${donor.bloodGroup}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Available for Donation",
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: donor.isAvailable,
                            onChanged: (v) {
                              controller.updateAvailability(v);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow("Age", donor.age.toString()),
                      _detailRow("Gender", donor.gender),
                      _detailRow("Phone", donor.phone),
                      _detailRow("Address", donor.address),
                      _detailRow(
                        "Last Donation",
                        donor.lastDonationDate == null
                            ? "Not yet donated"
                            : donor.lastDonationDate!.toString().substring(
                                0,
                                10,
                              ),
                      ),
                      _detailRow(
                        "Total Donations",
                        donor.totalDonations.toString(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Conditions
                if (donor.medicalConditions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Medical Conditions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...donor.medicalConditions.map((c) => Text("• $c")),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Notes
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(donor.notes!),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
