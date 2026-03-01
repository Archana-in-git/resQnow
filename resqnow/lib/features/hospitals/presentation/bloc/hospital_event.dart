import 'package:equatable/equatable.dart';

abstract class HospitalEvent extends Equatable {
  const HospitalEvent();
  @override
  List<Object?> get props => [];
}

class FetchApprovedHospitals extends HospitalEvent {
  const FetchApprovedHospitals();
}
