class EmergencyContact {
  final String name;
  final String number;

  EmergencyContact({required this.name, required this.number});

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      number: map['number'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'number': number};
  }
}
