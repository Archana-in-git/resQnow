import 'package:equatable/equatable.dart';
import '../../domain/entities/hospital_entity.dart';

abstract class HospitalState extends Equatable {
  const HospitalState();
  @override
  List<Object?> get props => [];
}

class HospitalInitial extends HospitalState {
  const HospitalInitial();
}

class HospitalLoading extends HospitalState {
  const HospitalLoading();
}

class HospitalLoaded extends HospitalState {
  final List<HospitalEntity> hospitals;
  const HospitalLoaded(this.hospitals);

  @override
  List<Object?> get props => [hospitals];
}

class HospitalError extends HospitalState {
  final String message;
  const HospitalError(this.message);

  @override
  List<Object?> get props => [message];
}
