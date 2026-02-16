import 'package:flutter/material.dart';
import '../data/profile_service.dart';
import '../data/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await _profileService.fetchUserProfile();
    setState(() {
      user = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No Profile Found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      /// PROFILE HEADER
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.teal),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user!.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(user!.email,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                      /// PERSONAL INFO CARD
                      buildCard(
                        title: "Personal Information",
                        children: [
                          buildRow("Phone", user!.phone),
                          buildRow("Gender", user!.gender),
                          buildRow("DOB", user!.dob),
                          buildRow("Blood Group", user!.bloodGroup),
                          buildRow("Address", user!.address),
                        ],
                      ),

                      /// MEDICAL INFO CARD
                      buildCard(
                        title: "Medical Information",
                        children: [
                          buildRow("Conditions",
                              user!.medicalConditions.join(", ")),
                          buildRow(
                              "Allergies", user!.allergies.join(", ")),
                          buildRow(
                              "Medications", user!.medications.join(", ")),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// LOGOUT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            await _profileService.logout();
                            Navigator.pushReplacementNamed(
                                context, '/login');
                          },
                          child: const Text("Logout"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DELETE ACCOUNT
                      TextButton(
                        onPressed: () => showDeleteDialog(),
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Widget buildCard(
      {required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to permanently delete your account?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _profileService.deleteAccount();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
