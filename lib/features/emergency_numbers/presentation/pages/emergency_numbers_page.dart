import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/data/models/emergency_number_model.dart';
import 'package:resqnow/features/emergency_numbers/data/services/emergency_number_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyNumbersPage extends StatefulWidget {
  const EmergencyNumbersPage({super.key});

  @override
  State<EmergencyNumbersPage> createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> {
  final EmergencyNumberService _service = EmergencyNumberService();
  late Future<List<EmergencyNumberModel>> _emergencyNumbersFuture;

  @override
  void initState() {
    super.initState();
    _emergencyNumbersFuture = _service.fetchEmergencyNumbers();
  }

  Future<void> _makePhoneCall(String number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    if (res == false && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to make call')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Numbers'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<EmergencyNumberModel>>(
        future: _emergencyNumbersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No emergency numbers found.'));
          }

          final numbers = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: numbers.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final item = numbers[index];
              return ListTile(
                title: Text(item.name, style: AppTextStyles.bodyText),
                subtitle: Text(item.number, style: AppTextStyles.caption),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _makePhoneCall(item.number),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
