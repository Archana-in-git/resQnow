import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/hospital_entity.dart';

class HospitalTile extends StatelessWidget {
  final HospitalEntity hospital;

  const HospitalTile({Key? key, required this.hospital}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          print('[HospitalTile] Tapped hospitalId: ${hospital.id}');
          context.push('/hospital-details/${hospital.id}');
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(hospital.address),
                const SizedBox(height: 4),
                Text(hospital.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
