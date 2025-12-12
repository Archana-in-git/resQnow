import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

class DonorCard extends StatelessWidget {
  final BloodDonor donor;
  final VoidCallback? onTap;

  const DonorCard({super.key, required this.donor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ---------------- PROFILE PHOTO ----------------
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: donor.profileImageUrl != null
                    ? NetworkImage(donor.profileImageUrl!)
                    : null,
                child: donor.profileImageUrl == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),

              const SizedBox(width: 16),

              // ---------------- DONOR INFO ----------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Blood group badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        donor.bloodGroup,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Address
                    Text(
                      donor.addressString,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
