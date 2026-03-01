import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';
import '../../domain/usecases/get_doctors_by_hospital.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetDoctorsByHospital getDoctorsByHospital;

  DoctorBloc({required this.getDoctorsByHospital}) : super(DoctorInitial()) {
    on<FetchDoctorsByHospital>((event, emit) async {
      emit(DoctorLoading());
      await emit.forEach(
        getDoctorsByHospital(event.hospitalId),
        onData: (doctors) => DoctorLoaded(doctors),
        onError: (error, stackTrace) => DoctorError(error.toString()),
      );
    });
  }
}
