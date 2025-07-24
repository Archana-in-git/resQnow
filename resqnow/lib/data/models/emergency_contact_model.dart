import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String number;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.number,
  });

  // Factory method to create from Firestore document
  factory EmergencyContact.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      name: data['name'] ?? '',
      number: data['number'] ?? '',
    );
  }

  // Convert to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {'name': name, 'number': number};
  }

  // Create a copy with new values (useful for updates)
  EmergencyContact copyWith({String? id, String? name, String? number}) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }
}
