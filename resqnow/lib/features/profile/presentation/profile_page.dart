import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../data/profile_service.dart';
import '../data/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _service = ProfileService();

  bool isLoading = true;
  bool isEditing = false;

  UserModel? user;

  File? _imageFile;
  String? _imageUrl;

  String phoneNumber = "";
  String gender = "Male";
  String bloodGroup = "O+";

  List<String> conditions = [];

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> bloodGroups = [
    "A+","A-","B+","B-","O+","O-","AB+","AB-"
  ];

  final List<String> medicalOptions = [
    "Airway Obstruction",
    "Allergic",
    "Anaphylaxis",
    "Asthma",
    "Broken Bone",
    "Burns",
    "Cardiac Arrest",
    "Chemical Burn",
    "Deep Cut",
    "Head Injury",
    "Insect Sting",
    "Muscle Strain",
    "Nosebleed",
    "Seizure",
    "Spinal Cord Injury",
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await _service.fetchUserProfile();
    if (!mounted) return;

    user = data;

    phoneNumber = user?.phone ?? "";
    gender = genders.contains(user?.gender) ? user!.gender : "Male";
    bloodGroup =
        bloodGroups.contains(user?.bloodGroup) ? user!.bloodGroup : "O+";
    conditions = List<String>.from(user?.medicalConditions ?? []);
    _imageUrl = user?.profileImageUrl;

    setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> saveProfile() async {
    String? imageUrl = _imageUrl;

    if (_imageFile != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images/$uid.jpg");

      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await _service.updateProfile({
      "phone": phoneNumber,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "medicalConditions": conditions,
      "profileImageUrl": imageUrl,
    });

    setState(() {
      _imageUrl = imageUrl;
      isEditing = false;
    });
  }

  /// ✅ FIXED MEDICAL SELECTOR (Checkbox works properly)
  void showMedicalSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: medicalOptions.map((option) {
                  final isSelected = conditions.contains(option);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(option),
                    activeColor: Colors.teal,
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    onChanged: (val) {
                      modalSetState(() {
                        if (val == true) {
                          if (!conditions.contains(option)) {
                            conditions.add(option); // prevent duplicate
                          }
                        } else {
                          conditions.remove(option);
                        }
                      });

                      setState(() {}); // update main screen
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                saveProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// PROFILE IMAGE
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : null) as ImageProvider?,
                  child: (_imageFile == null && _imageUrl == null)
                      ? const Icon(Icons.person,
                          size: 55, color: Colors.teal)
                      : null,
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 20),

            Text(user!.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),

            Text(user!.email,
                style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            /// PHONE
            IntlPhoneField(
              initialCountryCode: 'IN',
              enabled: isEditing,
              initialValue: phoneNumber,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              onChanged: (phone) {
                phoneNumber = phone.completeNumber;
              },
            ),

            const SizedBox(height: 15),

            /// GENDER
            DropdownButtonFormField<String>(
              value: genders.contains(gender) ? gender : null,
              items: genders
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: isEditing
                  ? (String? val) {
                      if (val != null) {
                        setState(() => gender = val);
                      }
                    }
                  : null,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            /// BLOOD GROUP
            DropdownButtonFormField<String>(
              value:
                  bloodGroups.contains(bloodGroup) ? bloodGroup : null,
              items: bloodGroups
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: isEditing
                  ? (String? val) {
                      if (val != null) {
                        setState(() => bloodGroup = val);
                      }
                    }
                  : null,
              decoration: const InputDecoration(
                labelText: "Blood Group",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            /// MEDICAL CONDITIONS
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Medical Conditions",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: isEditing ? showMedicalSelector : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Select Medical Conditions"),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: conditions
                  .map(
                    (e) => Chip(
                      label: Text(e),
                      backgroundColor: Colors.teal.shade50,
                      deleteIconColor: Colors.red,
                      onDeleted: isEditing
                          ? () {
                              setState(() {
                                conditions.remove(e);
                              });
                            }
                          : null,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              onPressed: showLogoutDialog,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content:
            const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _service.logout();
              if (mounted) context.go('/welcome');
            },
            child: const Text("Logout",
                style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
