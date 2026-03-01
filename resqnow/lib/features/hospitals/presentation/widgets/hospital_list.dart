import 'package:flutter/material.dart';
import '../../domain/entities/hospital_entity.dart';
import 'hospital_tile.dart';

class HospitalList extends StatelessWidget {
  final List<HospitalEntity> hospitals;

  const HospitalList({Key? key, required this.hospitals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hospitals.isEmpty) {
      return const Center(child: Text("No hospitals available"));
    }
    return ListView.builder(
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        return HospitalTile(hospital: hospitals[index]);
      },
    );
  }
}
