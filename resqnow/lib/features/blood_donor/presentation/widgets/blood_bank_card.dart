import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/domain/entities/blood_bank.dart';

class BloodBankCard extends StatelessWidget {
  final BloodBank bank;

  const BloodBankCard({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to details page
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade50.withValues(alpha: 0.6),
                      Colors.teal.shade50.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          _buildRatingSection(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildOpenStatusBadge(),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    _buildLocationSection(),
                    const SizedBox(height: 10),

                    // Action button
                    _buildActionButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenStatusBadge() {
    final isOpen = bank.isOpenNow ?? bank.openNow ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withValues(alpha: 0.9)
            : AppColors.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? "Open Now" : "Closed",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final rating = bank.rating ?? 0.0;
    final totalRatings = bank.userRatingsTotal ?? 0;

    return Row(
      children: [
        // Stars
        Row(
          children: [
            ...List.generate(
              5,
              (index) => Icon(
                index < rating.toInt()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber[600],
                size: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          "($totalRatings)",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Icon(Icons.location_on_rounded, color: AppColors.accent, size: 13),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            bank.address,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _openGoogleMapsDirections(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.directions_rounded, size: 16),
        label: const Text(
          "Get Directions",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMapsDirections() async {
    final lat = bank.latitude;
    final lng = bank.longitude;

    if (lng == null) {
      // Fallback to address if coordinates not available
      final String encodedAddress = Uri.encodeComponent(bank.address);
      final String mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(
          Uri.parse(mapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    // Use coordinates for directions (most accurate)
    final String directionsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(directionsUrl))) {
      await launchUrl(
        Uri.parse(directionsUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
