import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_filter_controller.dart';

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
    return Consumer<DonorFilterController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Filter Donors"),
            actions: [
              TextButton(
                onPressed: () {
                  controller.resetFilters();
                  setState(() {
                    ageRange = const RangeValues(18, 60);
                  });
                },
                child: const Text("Reset"),
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // BLOOD GROUP
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Blood Group",
                    border: OutlineInputBorder(),
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

                const SizedBox(height: 20),

                // GENDER
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
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

                const SizedBox(height: 20),

                // AGE RANGE
                const Text(
                  "Age Range",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: ageRange,
                  min: 18,
                  max: 100,
                  divisions: 82,
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

                const SizedBox(height: 20),

                // AVAILABILITY
                SwitchListTile(
                  title: const Text("Available for Donation"),
                  value: controller.isAvailable ?? false,
                  onChanged: (val) {
                    setState(() {
                      controller.isAvailable = val;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // APPLY BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            await controller.applyFilters();
                            if (!mounted) return;
                            navigator.pop(controller.filteredDonors);
                          },
                    child: controller.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text("Apply Filters"),
                  ),
                ),

                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
