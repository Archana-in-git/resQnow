import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../../domain/usecases/get_doctors_by_hospital.dart';

class HospitalDetailPage extends StatelessWidget {
  final String hospitalId;

  const HospitalDetailPage({Key? key, required this.hospitalId})
    : super(key: key);

  void _showBookingDialog(BuildContext context, doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. ${doctor.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Department: ${doctor.departmentName}'),
            Text('Experience: ${doctor.experienceYears} years'),
            Text(
              'Consultation: ${doctor.consultationStart} - ${doctor.consultationEnd}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Do you want to book a consultation with this doctor?',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/appointment-form/${hospitalId}/${doctor.id}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'Book Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final getDoctorsByHospital = context.read<GetDoctorsByHospital>();

    print('[HospitalDetailPage] hospitalId: $hospitalId');
    return BlocProvider(
      create: (context) =>
          DoctorBloc(getDoctorsByHospital: getDoctorsByHospital)
            ..add(FetchDoctorsByHospital(hospitalId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Hospital Details')),
        body: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorError) {
              return Center(child: Text(state.message));
            } else if (state is DoctorLoaded) {
              if (state.doctors.isEmpty) {
                return const Center(child: Text('No doctors available.'));
              }
              return ListView.builder(
                itemCount: state.doctors.length,
                itemBuilder: (context, index) {
                  final doctor = state.doctors[index];
                  return GestureDetector(
                    onTap: () => _showBookingDialog(context, doctor),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Department: ${doctor.departmentName}'),
                            const SizedBox(height: 4),
                            Text('Experience: ${doctor.experienceYears} years'),
                            const SizedBox(height: 4),
                            Text(
                              'Consultation: ${doctor.consultationStart} - ${doctor.consultationEnd}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
