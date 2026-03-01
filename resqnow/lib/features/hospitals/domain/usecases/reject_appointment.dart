import '../repositories/appointment_repository.dart';

class RejectAppointment {
  final AppointmentRepository repository;

  RejectAppointment(this.repository);

  Future<void> call(String appointmentId) {
    return repository.updateAppointmentStatus(appointmentId, 'rejected');
  }
}
