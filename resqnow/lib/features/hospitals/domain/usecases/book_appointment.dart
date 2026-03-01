import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class BookAppointment {
  final AppointmentRepository repository;

  BookAppointment(this.repository);

  Future<String> call(AppointmentEntity appointment) {
    return repository.bookAppointment(appointment);
  }
}
