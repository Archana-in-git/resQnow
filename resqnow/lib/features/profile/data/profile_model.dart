class UserModel {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String bloodGroup;
  final String address;
  final List<dynamic> medicalConditions;
  final List<dynamic> allergies;
  final List<dynamic> medications;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.medicalConditions,
    required this.allergies,
    required this.medications,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      medicalConditions: map['medicalConditions'] ?? [],
      allergies: map['allergies'] ?? [],
      medications: map['medications'] ?? [],
    );
  }
}
