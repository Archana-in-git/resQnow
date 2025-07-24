import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/features/emergency_numbers/data/services/emergency_number_service.dart';
import 'package:resqnow/data/models/emergency_contact_model.dart';

class EmergencyNumbersPage extends StatefulWidget {
  const EmergencyNumbersPage({Key? key}) : super(key: key);

  @override
  State<EmergencyNumbersPage> createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> {
  late Future<List<EmergencyContact>> _emergencyNumbers;

  @override
  void initState() {
    super.initState();
    _emergencyNumbers = EmergencyNumberService().fetchEmergencyNumbers();
  }

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Numbers")),
      body: FutureBuilder<List<EmergencyContact>>(
        future: _emergencyNumbers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading numbers"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No emergency numbers available."));
          }

          final numbers = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: numbers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final contact = numbers[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.lightGray,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name, style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 4),
                          Text(contact.number, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call, color: AppColors.primary),
                      onPressed: () => _callNumber(contact.number),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
