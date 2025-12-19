import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/authentication/presentation/controllers/auth_controller.dart';

class ResQNowNavBar extends StatelessWidget {
  const ResQNowNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.person, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Welcome to ResQNow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Drawer Menu Items
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.black87),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.local_hospital_outlined,
                color: Colors.black87,
              ),
              title: const Text("Nearby Hospitals"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.favorite_outline,
                color: Colors.black87,
              ),
              title: const Text("Saved Conditions"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.black87,
              ),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () async {
                Navigator.pop(context); // close drawer first
                await context.read<AuthController>().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
