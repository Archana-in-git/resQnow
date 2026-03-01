import 'package:equatable/equatable.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorsByHospital extends DoctorEvent {
  final String hospitalId;

  const FetchDoctorsByHospital(this.hospitalId);

  @override
  List<Object?> get props => [hospitalId];
}
