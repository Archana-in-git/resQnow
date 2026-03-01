import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hospital_bloc.dart';
import '../bloc/hospital_event.dart';
import '../bloc/hospital_state.dart';
import '../../domain/usecases/get_approved_hospitals.dart';
import '../widgets/hospital_list.dart';

class HospitalsPage extends StatelessWidget {
  const HospitalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HospitalBloc(
        getApprovedHospitals: context.read<GetApprovedHospitals>(),
      )..add(const FetchApprovedHospitals()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Hospitals')),
        body: BlocBuilder<HospitalBloc, HospitalState>(
          builder: (context, state) {
            if (state is HospitalLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HospitalError) {
              return Center(child: Text(state.message));
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
