import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import '../bloc/hospital_bloc.dart';
import '../bloc/hospital_event.dart';
import '../bloc/hospital_state.dart';
import '../../domain/usecases/get_approved_hospitals.dart';
import '../widgets/hospital_list.dart';

class HospitalsPage extends StatelessWidget {
  const HospitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => HospitalBloc(
        getApprovedHospitals: context.read<GetApprovedHospitals>(),
      )..add(const FetchApprovedHospitals()),
      child: Scaffold(
        backgroundColor: isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Approved Hospitals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        body: BlocBuilder<HospitalBloc, HospitalState>(
          builder: (context, state) {
            if (state is HospitalLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is HospitalError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading hospitals',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is HospitalLoaded) {
              return HospitalList(hospitals: state.hospitals);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
