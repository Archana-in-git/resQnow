import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import '../../domain/entities/hospital_entity.dart';
import 'hospital_tile.dart';

class HospitalList extends StatelessWidget {
  final List<HospitalEntity> hospitals;

  const HospitalList({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (hospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Hospitals Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No approved hospitals available in your area',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        return HospitalTile(hospital: hospitals[index]);
      },
    );
  }
}
