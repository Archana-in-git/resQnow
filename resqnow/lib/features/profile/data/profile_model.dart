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
  final String? profileImageUrl; 
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
    this.profileImageUrl,
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
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      profileImageUrl: map['profileImageUrl'], 
    );
  }
}
