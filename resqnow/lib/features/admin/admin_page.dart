import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  int totalUsers = 0;
  int totalEmergencies = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final emergencies = await FirebaseFirestore.instance
        .collection('emergencies')
        .get();

    if (!mounted) return;

    setState(() {
      totalUsers = users.docs.length;
      totalEmergencies = emergencies.docs.length;
      loading = false;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// USERS CARD
                  _buildCard(
                    title: "Total Users",
                    value: totalUsers.toString(),
                    icon: Icons.people,
                  ),

                  const SizedBox(height: 16),

                  /// EMERGENCY CARD
                  _buildCard(
                    title: "Total Emergencies",
                    value: totalEmergencies.toString(),
                    icon: Icons.warning,
                  ),

                  const SizedBox(height: 24),

                  /// USER LIST
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "All Users",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {

                          final user = docs[index];

                          return Card(
                            child: ListTile(
                              title: Text(user['name'] ?? ''),
                              subtitle: Text(user['email'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .delete();
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
