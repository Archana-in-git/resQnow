import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_bank.dart';

class BloodBankCard extends StatelessWidget {
  final BloodBank bank;

  const BloodBankCard({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(bank.name),
        subtitle: Text(bank.address),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: push details page later
        },
      ),
    );
  }
}
