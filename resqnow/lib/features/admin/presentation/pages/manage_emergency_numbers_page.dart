import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/data/models/emergency_contact_model.dart';
import 'package:resqnow/features/emergency_numbers/data/services/emergency_number_service.dart';
import 'package:resqnow/features/admin/widgets/admin_input_field.dart';

class ManageEmergencyNumbersPage extends StatefulWidget {
  const ManageEmergencyNumbersPage({Key? key}) : super(key: key);

  @override
  State<ManageEmergencyNumbersPage> createState() =>
      _ManageEmergencyNumbersPageState();
}

class _ManageEmergencyNumbersPageState
    extends State<ManageEmergencyNumbersPage> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addNumber() async {
    if (_formKey.currentState!.validate()) {
      await EmergencyNumberService().addEmergencyNumber(
        EmergencyContact(
          name: _nameController.text.trim(),
          number: _numberController.text.trim(),
        ),
      );
      _nameController.clear();
      _numberController.clear();
      setState(() {});
    }
  }

  Future<void> _deleteNumber(String id) async {
    await EmergencyNumberService().deleteEmergencyNumber(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Emergency Numbers")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AdminInputField(
                    controller: _nameController,
                    label: "Contact Name",
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  AdminInputField(
                    controller: _numberController,
                    label: "Phone Number",
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter phone number'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addNumber,
                    child: const Text("Add Number"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text("Existing Numbers", style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<EmergencyContact>>(
                stream: EmergencyNumberService().streamEmergencyNumbers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error loading numbers");
                  } else if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final contacts = snapshot.data!;
                  if (contacts.isEmpty) {
                    return const Text("No contacts available.");
                  }

                  return ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        tileColor: AppColors.lightGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          contact.name,
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: Text(
                          contact.number,
                          style: AppTextStyles.bodyMedium,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNumber(contact.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
