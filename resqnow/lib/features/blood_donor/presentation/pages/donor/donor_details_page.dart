import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            appBar: AppBar(),
            body: Center(
              child: Text(
                controller.errorMessage ?? "Donor not found.",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final donor = controller.donor!;

        return Scaffold(
          appBar: AppBar(title: Text(donor.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Image Card
                _profileHeader(donor),

                const SizedBox(height: 20),

                // Main Info Card
                _infoCard(donor),

                const SizedBox(height: 20),

                // Medical Conditions
                if (donor.medicalConditions.isNotEmpty) _conditionsCard(donor),

                const SizedBox(height: 20),

                // Notes
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  _notesCard(donor),

                const SizedBox(height: 20),

                // Call Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse("tel:${donor.phone}");
                      if (await canLaunchUrl(url)) {
                        launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.call),
                    label: const Text("Call Donor"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget _profileHeader(BloodDonor donor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            donor.bloodGroup,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BloodDonor donor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow("Age", donor.age.toString()),
          _infoRow("Gender", donor.gender),
          _infoRow("Phone", donor.phone),
          _infoRow("Address", donor.address),
          _infoRow(
            "Last Donation",
            donor.lastDonationDate == null
                ? "Not yet donated"
                : donor.lastDonationDate.toString().substring(0, 10),
          ),
          _infoRow("Total Donations", donor.totalDonations.toString()),
          _infoRow("Available", donor.isAvailable ? "Yes" : "No"),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _conditionsCard(BloodDonor donor) {
    return Container(
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...donor.medicalConditions.map(
            (condition) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(condition)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BloodDonor donor) {
    return Container(
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(donor.notes!, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
