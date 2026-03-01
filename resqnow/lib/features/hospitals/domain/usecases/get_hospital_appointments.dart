import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetHospitalAppointments {
  final AppointmentRepository repository;

  GetHospitalAppointments(this.repository);

  Future<List<AppointmentEntity>> call(String hospitalId) {
    return repository.getHospitalAppointments(hospitalId);
  }
}
