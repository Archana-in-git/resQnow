import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BloodLandingPage extends StatelessWidget {
  const BloodLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fbf8), // soft greenish pastel bg
      body: SafeArea(
        child: Column(
          children: [
            // 🌈 TOP HEADER WITH CURVED SHAPE
            _Header(),

            const SizedBox(height: 20),

            // 🔘 NAVIGATION OPTIONS
            _LandingButtons(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffd8f3dc), Color(0xffb7e4c7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.bloodtype, size: 70, color: Colors.red),
            ),
          ),
        ),
        const Positioned(
          left: 20,
          top: 40,
          child: Text(
            "Blood Help Center",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1b4332),
            ),
          ),
        ),
      ],
    );
  }
}

class _LandingButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _NavCard(
            title: "Nearby Blood Banks",
            subtitle: "Find hospitals & certified banks",
            icon: Icons.local_hospital,
            color: Colors.redAccent,
            onTap: () => context.push('/blood-banks'),
          ),

          _NavCard(
            title: "Become a Donor",
            subtitle: "Register & help save a life",
            icon: Icons.volunteer_activism,
            color: Colors.green,
            onTap: () => context.push('/donor/register'),
          ),

          _NavCard(
            title: "Nearby Donors",
            subtitle: "Find donors around you",
            icon: Icons.people_alt,
            color: Colors.blueAccent,
            onTap: () => context.push('/donors'),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
