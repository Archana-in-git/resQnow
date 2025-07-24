import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyNumberModel {
  final String id;
  final String name;
  final String number;

  EmergencyNumberModel({
    required this.id,
    required this.name,
    required this.number,
  });

  factory EmergencyNumberModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyNumberModel(
      id: doc.id,
      name: data['name'] ?? '',
      number: data['number'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'number': number};
  }
}
