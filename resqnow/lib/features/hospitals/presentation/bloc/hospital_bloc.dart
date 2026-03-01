import 'package:flutter_bloc/flutter_bloc.dart';
import 'hospital_event.dart';
import 'hospital_state.dart';
import '../../domain/usecases/get_approved_hospitals.dart';

class HospitalBloc extends Bloc<HospitalEvent, HospitalState> {
  final GetApprovedHospitals getApprovedHospitals;

  HospitalBloc({required this.getApprovedHospitals})
    : super(const HospitalInitial()) {
    on<FetchApprovedHospitals>(_onFetchApprovedHospitals);
  }

  Future<void> _onFetchApprovedHospitals(
    FetchApprovedHospitals event,
    Emitter<HospitalState> emit,
  ) async {
    emit(const HospitalLoading());

    await emit.forEach(
      getApprovedHospitals(),
      onData: (hospitals) => HospitalLoaded(hospitals),
      onError: (error, stackTrace) => HospitalError(error.toString()),
    );
  }
}
