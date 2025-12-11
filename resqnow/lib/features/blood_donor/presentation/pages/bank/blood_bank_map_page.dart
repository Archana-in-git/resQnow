import 'package:flutter/material.dart';

class BloodBankMapPage extends StatelessWidget {
  const BloodBankMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blood Banks Map View")),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300, width: 2),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                "Map view will be added soon.\n\n"
                "This is a placeholder until Google Maps API is set up.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
