import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_bank.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankDetailsPage extends StatelessWidget {
  final BloodBank bank;

  const BloodBankDetailsPage({super.key, required this.bank});

  void _openMaps(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bank.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  bank.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 22, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bank.address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Rating + Open Now
                Row(
                  children: [
                    if (bank.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            bank.rating!.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                    const SizedBox(width: 20),

                    if (bank.openNow != null)
                      Row(
                        children: [
                          Icon(
                            bank.openNow! ? Icons.check_circle : Icons.cancel,
                            color: bank.openNow! ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            bank.openNow! ? "Open Now" : "Closed",
                            style: TextStyle(
                              fontSize: 16,
                              color: bank.openNow! ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openMaps(bank.latitude, bank.longitude);
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text("Directions"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: bank.phoneNumber == null
                            ? null
                            : () async {
                                final url = Uri.parse(
                                  "tel:${bank.phoneNumber}",
                                );
                                await launchUrl(url);
                              },
                        icon: const Icon(Icons.phone),
                        label: const Text("Call"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Placeholder Map Container
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Map preview coming soon",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
