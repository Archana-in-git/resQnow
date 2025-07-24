import 'package:flutter/material.dart';
import 'package:resqnow/data/models/emergency_number_model.dart';
import 'package:resqnow/features/emergency_numbers/data/services/emergency_number_service.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/features/admin/presentation/widgets/admin_input_field.dart';
import 'package:resqnow/features/admin/presentation/widgets/admin_section_title.dart';

class ManageEmergencyNumbersPage extends StatefulWidget {
  const ManageEmergencyNumbersPage({super.key});

  @override
  State<ManageEmergencyNumbersPage> createState() =>
      _ManageEmergencyNumbersPageState();
}

class _ManageEmergencyNumbersPageState
    extends State<ManageEmergencyNumbersPage> {
  final EmergencyNumberService _service = EmergencyNumberService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<EmergencyNumberModel> _numbers = [];
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final list = await _service.fetchEmergencyNumbers();
    setState(() {
      _numbers = list;
    });
  }

  Future<void> _saveNumber() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();
    if (name.isEmpty || number.isEmpty) return;

    if (_editingId != null) {
      await _service.updateEmergencyNumber(
        EmergencyNumberModel(id: _editingId!, name: name, number: number),
      );
    } else {
      await _service.addEmergencyNumber(
        EmergencyNumberModel(id: '', name: name, number: number),
      );
    }

    _clearFields();
    _loadNumbers();
  }

  void _clearFields() {
    _nameController.clear();
    _numberController.clear();
    _editingId = null;
  }

  Future<void> _deleteNumber(String id) async {
    await _service.deleteEmergencyNumber(id);
    _loadNumbers();
  }

  void _editNumber(EmergencyNumberModel model) {
    _nameController.text = model.name;
    _numberController.text = model.number;
    _editingId = model.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Emergency Numbers'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AdminSectionTitle(title: 'Add / Edit Number'),
            const SizedBox(height: 8),
            AdminInputField(controller: _nameController, label: 'Name'),
            const SizedBox(height: 8),
            AdminInputField(controller: _numberController, label: 'Number'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveNumber,
              child: Text(_editingId == null ? 'Add Number' : 'Update Number'),
            ),
            const SizedBox(height: 24),
            const AdminSectionTitle(title: 'Existing Entries'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _numbers.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _numbers[index];
                  return ListTile(
                    title: Text(item.name, style: AppTextStyles.bodyText),
                    subtitle: Text(item.number),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editNumber(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNumber(item.id),
                        ),
                      ],
                    ),
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
